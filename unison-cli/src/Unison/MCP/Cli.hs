module Unison.MCP.Cli
  ( handleInputMCP,
    ppForProjectContext,
    cliToMCP,
    virtualSourceName,
  )
where

import Control.Monad.Except (ExceptT (..), throwError)
import Control.Monad.Reader
import Crypto.Random qualified as Random
import Data.Aeson
import Data.IORef
import Data.Sequence qualified as Seq
import U.Codebase.Sqlite.Queries qualified as Queries
import Unison.Auth.CredentialManager qualified as AuthN
import Unison.Auth.HTTPClient qualified as AuthN
import Unison.Auth.Tokens qualified as AuthN
import Unison.Cli.Monad qualified as Cli
import Unison.Codebase qualified as Codebase
import Unison.Codebase.Editor.HandleInput qualified as HandleInput
import Unison.Codebase.Editor.Input (Event, Input)
import Unison.Codebase.Editor.Output qualified as Output
import Unison.Codebase.Path qualified as Path
import Unison.Codebase.ProjectPath qualified as PP
import Unison.CommandLine (defaultLoadSourceFile, defaultWriteSourceFile)
import Unison.CommandLine.OutputMessages qualified as Output
import Unison.MCP.Types
import Unison.MCP.Types qualified as MCP
import Unison.Prelude
import Unison.Sqlite (Transaction)
import Unison.Syntax.Parser qualified as Parser
import Unison.Util.Pretty qualified as Pretty
import UnliftIO.STM
import Prelude hiding (readFile, writeFile)

virtualSourceName :: Text
virtualSourceName = "<mcp-virtual-source>"

data CliOutput = CliOutput
  { sourceCodeUpdates :: [Text],
    outputMessages :: [Text],
    errorMessages :: [Text]
  }
  deriving (Eq, Show)

instance Semigroup CliOutput where
  CliOutput src1 out1 errs1 <> CliOutput src2 out2 errs2 =
    CliOutput (src1 <> src2) (out1 <> out2) (errs1 <> errs2)

instance Monoid CliOutput where
  mempty = CliOutput [] [] []

instance ToJSON CliOutput where
  toJSON (CliOutput sourceCodeUpdates outputMessages errorMessages) =
    object
      [ "sourceCodeUpdates" .= sourceCodeUpdates,
        "outputMessages" .= outputMessages,
        "errorMessages" .= errorMessages
      ]

ppForProjectContext :: ProjectContext -> ExceptT Text Transaction PP.ProjectPath
ppForProjectContext ProjectContext {projectName, branchName} = do
  project <-
    lift (Queries.loadProjectByName projectName) & onNothingM do
      throwError $ "Project not found: " <> into @Text projectName
  branch <-
    lift (Queries.loadProjectBranchByName project.projectId branchName) >>= \case
      Nothing -> throwError $ "Branch not found: " <> into @Text branchName
      Just projectBranch -> pure projectBranch
  pure $ PP.fromProjectAndBranch (PP.ProjectAndBranch project branch) Path.Root

handleInputMCP :: ProjectContext -> [Either Event Input] -> ExceptT Text MCP CliOutput
handleInputMCP projectContext input = do
  hasErroredVar <- newTVarIO False
  let onErr _errMsg = atomically $ writeTVar hasErroredVar True
  result <- cliToMCP projectContext onErr do
    Cli.labelE \fail' -> do
      for_ input \inp -> do
        HandleInput.loop inp
        readTVarIO hasErroredVar >>= \case
          False -> pure ()
          True -> fail' "An error occurred during input handling."
  case result of
    (Nothing, cliOut) -> pure cliOut
    (Just (Left err), cliOutput) ->
      pure $ cliOutput <> mempty {errorMessages = [err]}
    (Just (Right ()), cliOutput) ->
      pure cliOutput

cliToMCP :: ProjectContext -> (Text -> IO ()) -> Cli.Cli a -> ExceptT Text MCP (Maybe a, CliOutput)
cliToMCP projCtx onError cli = do
  MCP.Env {ucmVersion, codebase, runtime, workDir} <- ask
  initialPP <- ExceptT . liftIO $ Codebase.runTransactionExceptT codebase $ do
    ppForProjectContext projCtx
  credMan <- AuthN.newCredentialManager
  let tokenProvider :: AuthN.TokenProvider
      tokenProvider = AuthN.newTokenProvider credMan
  authenticatedHTTPClient <- AuthN.newAuthenticatedHTTPClient tokenProvider ucmVersion
  outputVar <- newTVarIO Seq.empty
  errorsVar <- newTVarIO Seq.empty
  sourceCodeUpdatesVar <- newTVarIO Seq.empty
  let notify output = do
        pretty <- Output.notifyUser workDir Output.fetchIssueFromGitHub output
        if (Output.isFailure output)
          then do
            atomically $ modifyTVar errorsVar (<> Seq.singleton pretty)
            liftIO $ onError (Pretty.toPlain 0 pretty)
          else do
            atomically $ modifyTVar outputVar (<> Seq.singleton pretty)
  let notifyNumbered output = do
        let (pretty, nargs) = Output.notifyNumbered output
        atomically $ modifyTVar outputVar (<> Seq.singleton pretty)
        pure nargs

  let writeSource sourceName content replace = do
        if sourceName == virtualSourceName
          then
            if replace
              then do
                atomically $ writeTVar sourceCodeUpdatesVar (Seq.singleton content)
              else do
                atomically $ modifyTVar sourceCodeUpdatesVar (<> Seq.singleton content)
          else do
            defaultWriteSourceFile sourceName content replace

  seedRef <- liftIO $ newIORef (0 :: Int)
  let cliEnv =
        Cli.Env
          { authHTTPClient = authenticatedHTTPClient,
            codebase,
            credentialManager = credMan,
            generateUniqueName = do
              i <- atomicModifyIORef' seedRef \i -> let !i' = i + 1 in (i', i)
              pure (Parser.uniqueBase32Namegen (Random.drgNewSeed (Random.seedFromInteger (fromIntegral i)))),
            loadSource = defaultLoadSourceFile,
            lspCheckForChanges = \_ -> pure (),
            writeSource,
            notify,
            notifyNumbered,
            runtime,
            sandboxedRuntime = error "Sandboxed runtime not implemented in MCP Server",
            serverBaseUrl = Nothing,
            ucmVersion,
            isTranscriptTest = False
          }

  let startState = (Cli.loopState0 (PP.toIds initialPP))
  -- The actual output isn't important, all communication comes from notify, notifyNumbered, and writeSource.
  (cliResult, _loopState) <- liftIO (Cli.runCli cliEnv startState cli)
  -- flush the output buffer since it should now be filled.
  cliOut <- atomically $ do
    msgs <- readTVar outputVar
    errs <- readTVar errorsVar
    sourceCodeUpdates <- toList <$> readTVar sourceCodeUpdatesVar
    let outputMessages =
          msgs
            & fmap (Pretty.toPlain 0)
            & toList
    let errorMessages =
          errs
            & fmap (Pretty.toPlain 0)
            & toList
    pure $
      ( CliOutput
          { sourceCodeUpdates,
            outputMessages,
            errorMessages
          }
      )
  case cliResult of
    Cli.Continue -> pure (Nothing, cliOut)
    Cli.HaltRepl -> pure (Nothing, cliOut)
    Cli.Success a -> pure (Just a, cliOut)

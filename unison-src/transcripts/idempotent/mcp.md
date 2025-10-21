``` ucm
scratch/main> builtins.mergeio lib.builtins

  Done.
```

``` unison :hide
README = {{
  This is a scratch project for testing tools in MCP.
}}

myTerm = 99

type MyType = MyConstructor

test> myPassingTest = [Ok "passing"]
test> myFailingTest = [Fail "failing"]
```

``` ucm
scratch/main> update

  Okay, I'm searching the branch for code that needs to be
  updated...

  Done.
```

## list-project-branches

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "list-project-branches",
      "arguments": {
        "projectName": "scratch"
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"     Branch   Remote branch\\n1.   main     \"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## typecheck-code

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "typecheck-code",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }, "code": {"sourceCode": "> x = 1 + 2"}
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"Loading changes detected in <mcp-virtual-source>.\",\"No changes found.\",\"  1 | > x = 1 + 2\\n        â§©\\n        3\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## docs

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "docs",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }, "name": "README"
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"This is a scratch project for testing tools in MCP.\\n\\n\\n\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## list-project-definitions

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "list-project-definitions",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"content\":[{\"text\":\"{\\\"errorMessages\\\":[],\\\"outputMessages\\\":[\\\"1. myFailingTest : [Result]\\\\n2. myPassingTest : [Result]\\\\n3. myTerm : Nat\\\\n4. type MyType\\\\n5. MyType.MyConstructor : MyType\\\\n6. README : Doc2\\\\n\\\"],\\\"sourceCodeUpdates\\\":[]}\",\"type\":\"text\"}],\"isError\":false}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## list-project-libraries

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "list-project-libraries",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"1. builtins. (840 terms, 121 types)\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## list-project-branches

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "list-project-branches",
      "arguments": {
        "projectName": "scratch"
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"     Branch   Remote branch\\n1.   main     \"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## view-definitions

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "view-definitions",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }, "names": ["myTerm", "MyType"]
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"type MyType = MyConstructor\\n\\nmyTerm : Nat\\nmyTerm = 99\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## search-definitions-by-name

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "search-definitions-by-name",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }, "query": "my"
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"1. myFailingTest : [Result]\\n2. myPassingTest : [Result]\\n3. myTerm : Nat\\n4. type MyType\\n5. MyType.MyConstructor : MyType\\n\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## search-by-type

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "search-by-type",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }, "query": "Nat"
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"1. myTerm : Nat\\n\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## get-current-project-context

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "get-current-project-context",
      "arguments": { }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"branchName\":\"main\",\"projectName\":\"scratch\"}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## tests

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "run-tests",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "main"
        }
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"Cached test results (`help testcache` to learn more)\\n\\n  1. myPassingTest   â passing\\n\\n  2. myFailingTest   â failing\\n\\nð« 1 test(s) failing, â 1 test(s) passing\\n\\nTip: Use view 1 to view the source of a test.\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

## update-definitions

MCP can't edit branches unless they are marked as editable.

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "update-definitions",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "uneditable"
        }, "code": {"text": "myTerm = 100"}
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "The provided project-branch is not editable.\nPlease ask the user to allow edits to this project in their MCP configuration by adding `--mcp-editable-branches=scratch/uneditable` to the invocation of the Unison mcp within their agent's mcp configuration.",
                  "type": "text"
              }
          ],
          "isError": true
      }
  }

```

Transcripts allow mcp-editing on `agent-*` branches.

``` ucm
scratch/agent-foo> builtins.merge lib.builtins

  Done.
```

``` api
POST /mcp
BODY:
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "update-definitions",
      "arguments": {
        "projectContext": {
          "projectName": "scratch",
          "branchName": "agent-foo"
        }, "code": {"text": "myTerm = 100"}
      }
    }
  }

RESPONSE:
  {
      "id": 1,
      "jsonrpc": "2.0",
      "result": {
          "content": [
              {
                  "text": "{\"errorMessages\":[],\"outputMessages\":[\"Loading changes detected in <mcp-virtual-source>.\",\"+ myTerm : Nat\\n\\nRun `update` to apply these changes to your codebase.\",\"Done.\"],\"sourceCodeUpdates\":[]}",
                  "type": "text"
              }
          ],
          "isError": false
      }
  }

```

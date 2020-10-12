# API

- - - -
## GET diff(id,old_files,new_files)
The diff of two sets of files.
- returns
  * unchanged lines as type "same" using line numbers from **new_files**
  * added lines as type "added" using line numbers from **new_files**
  * deleted lines as type "deleted" using line numbers from **old_files**
  * each added/deleted hunk as indexed "sections"
  * eg
  ```json
  {
    "created.filename":
    [
      { "type": "section", "index": 0 },
      { "type": "added", "line": "this file", "number": 1 },
      { "type": "added", "line": "is new",    "number": 2 }
    ],
    ...
  }
  ```
  * a deleted file as all lines :deleted
  ```json
  {
    "deleted.filename":
    [
      { "type": "section", "index": 0 },      
      { "type": "deleted", "line": "this file",   "number": 1 },
      { "type": "deleted", "line": "had 2 lines", "number": 2 }
    ],
    ...
  }
  ```
  *
- parameters
  * **id:String** for tracing
  * **old_files:Hash{String=>String}**
  * **new_files:Hash{String=>String}**
  * eg
  ```json
  { "old_files": {
      "hiker.h": "#ifndef HIKER_INCLUDED...",
      "hiker.c": "#include <stdio.h>...",
      "hiker.tests.c": "#include <assert.h>...",
      "cyber-dojo.sh": "make",
      "makefile": "..."
    },
    "new_files": {
      "fizz_buzz.h": "#ifndef FIZZ_BUZZ_INCLUDED...",
      "hiker.c": "#include <stdio.h>...",
      "hiker.tests.c": "#include <assert.h>...",
      "cyber-dojo.sh": "make",
      "makefile": "...some-edits..."
    }
  }
  ```

- - - -
## GET diff_tip_data(id,old_files,new_files)
The summary data of a diff of the two sets of files.
Specifically, the names of the files that have changed,
and for each file, the number of added and deleted lines.

- - - -
# GET alive?
Useful as a Kubernetes liveness probe.
- returns
  * **true**
  ```json
  { "ready?": true }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET ready?
Useful as a Kubernetes readyness probe.
- returns
  * **true** if the service is ready
  ```json
  { "ready?": true }
  ```
  * **false** if the service is not ready
  ```json
  { "ready?": false }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET sha
The git commit sha used to create the Docker image.
Present inside the image as the environment variable COMMIT_SHA.
- returns
  * The 40 character sha string.
  * eg
  ```json
  { "sha": "b28b3e13c0778fe409a50d23628f631f87920ce5" }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
## JSON in
- All methods pass any arguments as a json hash in the http request body.
- If there are no arguments you can use `''` (which is the default
  for `curl --data`) instead of `'{}'`.

- - - -
## JSON out      
- All methods return a json hash in the http response body.
- If the method completes, a key equals the method's name. eg
  ```bash
  $ curl --silent --request GET http://${IP_ADDRESS}:${PORT}/ready?
  { "ready?":true}
  ```
- If the method raises an exception, a key equals `"exception"`, with
  a json-hash as its value. eg

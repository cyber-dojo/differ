[![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ)

# cyberdojo/differ docker image

- The source for the [cyberdojo/differ](https://hub.docker.com/r/cyberdojo/differ/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- Diffs two sets of files.

- - - -
# API
  * [GET diff(id,old_files,new_files)](#get-diffidold_filesnew_files)
  * [GET ready?](#get-ready)
  * [GET alive?](#get-alive)  
  * [GET sha](#get-sha)

- - - -
# JSON in, JSON out  
* All methods receive a JSON hash.
  * The hash contains any method arguments as key-value pairs.
* All methods return a JSON hash.
  * If the method completes, a key equals the method's name.
  * If the method raises an exception, a key equals "exception".

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
  * **id:String** for tracing, must be in [base58](https://github.com/cyber-dojo/differ/blob/master/src/base58.rb)
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
# GET ready?
Useful as a readiness probe.
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
# GET alive?
Useful as a liveness probe.
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
# GET sha
The git commit sha used to create the Docker image.
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
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

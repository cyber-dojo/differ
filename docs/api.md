# API

- - - -
## GET diff_files(id,was_index,now_index)
A diff of two sets of files from the kata with id **id**,
the set is the files with index **was_index**,
the set is the files with index **now_index**.
Also includes unchanged files and the content of identically renamed files.
- returns an Array of Hashes with each Hash being the diff of a single file. Each Hash has the following keys:
  * "type" - one of the Strings [ "created", "deleted", "renamed", "changed", "unchanged" ].
  * "old_filename" - the String name of the file, unless "type" is "created" in which case it is **null**.
  * "new_filename" - the String name of the file, unless "type" is "deleted" in which case it is **null**.
  * "lines" - an Array of Hashes, each Hash detailing an "added", "deleted", or "same" line, or
    a "section" marker before a diff-chunk.
  * "added" - line numbers index into **now_index**'s file.
  * "deleted" - line numbers index into **was_index**'s file.
  * "same" - line numbers index into **now_index**'s file.
  *
  * eg a newly created file
  ```json
  [
    {
      "type": "created",
      "old_filename": null,
      "new_filename": "the.created.filename",
      "lines":
      [
        { "type": "section", "index": 0 },              
        { "type": "added", "line": "this file", "number": 1 },
        { "type": "added", "line": "is new",    "number": 2 }
      ],
      "line_counts": { "added":2, "deleted":0, "same":0 }
    }
    ,
    ...
  ]
  ```
  * eg a deleted file
  ```json
  [
    {
      "type": "deleted",
      "old_filename": "the.deleted.filename",
      "new_filename": null,
      "lines":
      [
        { "type": "section", "index": 0 },      
        { "type": "deleted", "line": "this file",   "number": 1 },
        { "type": "deleted", "line": "had 2 lines", "number": 2 }
      ],
      "line_counts": { "added":0, "deleted":2, "same":0 }
    }
    ,
    ...
  ]
  ```
  * eg a 100% identical renamed file
  ```json
  [
    {
      "type": "renamed",
      "old_filename": "the.old.filename",
      "new_filename": "the.new.filename",
      "lines":
      [
        { "type": "same", "line": "this file has",   "number": 1 },
        { "type": "same", "line": "changed its name", "number": 2 }
        { "type": "same", "line": "but not its contents", "number": 3 }
      ],
      "line_counts": { "added":0, "deleted":0, "same":3 }
    }
    ,
    ...
  ]
  ```
  * eg a file with two diff-chunks
  ```json
  [
    {
      "type": "changed",
      "old_filename": "hiker.h",
      "new_filename": "hiker.h",
      "lines":
      [
        { "type": "same", "line": "#ifndef HIKER_INCLUDED",   "number": 1 },
        { "type": "section", "index": 0 },              
        { "type": "deleted", "line": "#define WIBBLE",   "number": 2 },
        { "type": "added",   "line": "#define HIKER_INCLUDED", "number": 2 },
        { "type": "same", "line": "", "number": 3 },
        { "type": "section", "index": 1 },              
        { "type": "deleted", "line": "struct wibble",   "number": 3 },
        { "type": "added",   "line": "struct hiker", "number": 3 },
        { "type": "same", "line": "{", "number": 4 },        
        { "type": "same", "line": "};", "number": 5 },        
        { "type": "same", "line": "#endif", "number": 6 },        
      ],
      "line_counts": { "added":2, "deleted":2, "same":5 }
    }
    ,
    ...
  ]
  ```

- parameters
  * **id:String** for tracing
  * **was_index:Integer**
  * **now_index:Integer**
  * eg
  ```json
  { "id":"qs34Rk", "was_index":3, "now_index":4 }
  ```

- - - -
## GET diff_summary(id,was_index,now_index)
The same as `diff_lines` except its Hash entries does *not* include "lines".

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
# GET alive
Useful as a Kubernetes liveness probe.
- returns
  * **true**
  ```json
  { "alive": true }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET healthy
Useful as a Docker heathcheck probe.
- returns
  * **true** if the service is healthy
  ```json
  { "healthy": true }
  ```
  * **false** if the service is not healthy
  ```json
  { "healthy": false }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET ready
Useful as a Kubernetes readyness probe.
- returns
  * **true** if the service is ready
  ```json
  { "ready": true }
  ```
  * **false** if the service is not ready
  ```json
  { "ready": false }
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

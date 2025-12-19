# API

- - - -
## GET diff_lines(id,was_index,now_index)
A diff of two sets of files (designated with **was_index** and **now_index**) from the kata designated with **id**.
Also includes unchanged files and the content of files renamed but with identical content.
- parameters
  * **id:String** the id of the kata.
  * **was_index:Integer** the test-submission index of the first set of files.
  * **now_index:Integer** the test-submission index of the second set of files.
  * eg the diff between the 3rd and 4th test submissions of kata "qs34Rk"
  ```json
  { "id":"qs34Rk", "was_index":3, "now_index":4 }
  ```
- returns an Array of Hashes with each Hash being the diff of a single file. Each Hash has the following keys:
  * "type" - one of the Strings [ "created", "deleted", "renamed", "changed", "unchanged" ].
  * "old_filename" - the String name of the **was_index** file, unless "type" is "created" in which case **null**.
  * "new_filename" - the String name of the **now_index** file, unless "type" is "deleted" in which case **null**.
  * "lines" - an Array of Hashes, each Hash detailing an "added", "deleted", or "same" line, or
    a "section" marker before a diff-chunk.
  * "line_counts" - a Hash with three entries:
    - "added" - the number of lines added to **now_index**'s "new_filename" file.
    - "deleted" - the number of lines deleted from **was_index**'s "old_filename" file.
    - "same" - the number of lines identical in **now_index**'s "new_filename" file and **was_index**'s "old_filename" file.
  *
  * eg a created file, which always has a single "section" marker.
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
  * eg a deleted file, which always has a single "section" marker.
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
  * eg a renamed file with identical content, which always has zero "section" markers.
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
  * eg a changed file with two diff-chunks.
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

- - - -
## GET diff_summary(id,was_index,now_index)
The same as `diff_lines` except its Hash entries do *not* include "lines".
* eg a file with changes spread across one or more diff-chunks.
```json
[
  {
    "type": "changed",
    "old_filename": "hiker.cpp",
    "new_filename": "hiker.cpp",
    "line_counts": { "added":22, "deleted":29, "same":57 }
  }
  ,
  ...
]
```

- - - -
## GET alive?
The runtime liveness probe to see if the service is alive.  
- parameters
  * none
- result 
  * **true**
- example
  ```bash     
  $ curl --fail --silent --request GET https://${DOMAIN}:${PORT}/alive?
  ```
  ```bash
  {"alive?":true}
  ```


- - - -
## GET ready?
The runtime readiness probe to see if the service is ready to handle requests.  
- parameters
  * none
- result 
  * **true** when the service is ready
  * **false** when the service is not ready
- example
  ```bash     
  $ curl --fail --silent --request GET https://${DOMAIN}:${PORT}/ready?
  ```
  ```bash
  {"ready?":false}
  ```


- - - -
## GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
- result 
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --fail --silent --request GET https://${DOMAIN}:${PORT}/sha
  ```
  ```bash
  {"sha":"b28b3e13c0778fe409a50d23628f631f87920ce5"}
  ```

- - - -
## JSON in
- All methods can pass any arguments either as a JSON Hash in the http request body, or in the query string of the URL.
- If there are no arguments you can use `''` (which is the default for `curl --data`) instead of `'{}'`.

- - - -
## JSON out      
- All methods return a JSON Hash in the http response body.
- If the method completes, a key equals the method's name. eg
  ```bash
  $ curl --silent --request GET https://${DOMAIN}:${PORT}/ready
  { "ready":true }
  ```
- If the method raises an exception, a key equals `"exception"`.

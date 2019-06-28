
[![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ)

# cyberdojo/differ docker image

- The source for the [cyberdojo/differ](https://hub.docker.com/r/cyberdojo/differ/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- Diffs two sets of files.

- - - -
# API
  * [GET diff(was_files,now_files)](#get-diffwas_filesnow_files)
  * [GET ready?](#get-ready)
  * [GET sha](#get-sha)

- - - -
# JSON in, JSON out  
* All methods receive a JSON hash.
  * The hash contains any method arguments as key-value pairs.
* All methods return a JSON hash.
  * If the method completes, a key equals the method's name.
  * If the method raises an exception, a key equals "exception".

- - - -
## GET diff(was_files,now_files)
Returns the diff of two sets of files.
- parameters
  * **was_files:Hash{String=>String}**
  * **now_files:Hash{String=>String}**
  * eg
  ```json
  { "was_files": {
      "hiker.h": "#ifndef HIKER_INCLUDED...",
      "hiker.c": "#include <stdio.h>...",
      "hiker.tests.c": "#include <assert.h>...",
      "cyber-dojo.sh": "make",
      "makefile": "..."
    },
    "now_files": {
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
- parameters
  * none
  ```json
  {}
  ```
- returns
  * **true** if the service is ready
  * **false** if the service is not ready
  * eg
  ```json
  { "ready?": true }
  { "ready?": false }
  ```

- - - -
# GET sha
- parameters
  * none
  ```json
  {}
  ```
- returns
  * the git commit sha used to create the docker image
  * eg
  ```json
  { "sha": "b28b3e13c0778fe409a50d23628f631f87920ce5" }
  ```

- - - -

```
./sh/run_demo.sh
```

Creates two docker images; a diff-client and a diff-server,
and creates a container from each image.
The diff-client container sends two sets of files (in a json body) to the
diff-server-container which returns their processed diff. The diff-client runs
on port 4568 and the diff-server on port 4567. If the diff-client's IP address
is 192.168.99.100 then put 192.168.99.100:4568 into your browser to see the
processed diff.

```
./pipe_build_up_test.sh
```

Rebuilds the images and runs the tests inside the
differ-server and differ-client containers.

...

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

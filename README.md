
[![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ)

# cyberdojo/differ docker image

- The source for the [cyberdojo/differ](https://hub.docker.com/r/cyberdojo/differ/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- Diffs two sets of files.

- - - -
API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- - - -
## GET diff
Returns the diff of two sets of files.
- parameters
  * was_files, eg
  ```json
    { "hiker.h": "#ifndef HIKER_INCLUDED...",
      "hiker.c": "#include <stdio.h>...",
      "hiker.tests.c": "#include <assert.h>...",
      "cyber-dojo.sh": "make",
      "makefile": "..."
    }
  ```
  * now_files, eg
  ```json
    { "fizz_buzz.h": "#ifndef FIZZ_BUZZ_INCLUDED...",
      "hiker.c": "#include <stdio.h>...",
      "hiker.tests.c": "#include <assert.h>...",
      "cyber-dojo.sh": "make",
      "makefile": "...some-edits..."
    }
  ```

- - - -
## GET ready?()
- parameters, none
```json
  {}
```
- returns true if the service is ready, otherwise false, eg
```json
  { "ready?": true }
  { "ready?": false }
```

- - - -
## GET sha
Returns the git commit sha used to create the docker image.
- parameters, none
```json
  {}
```
- returns the sha, eg
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


[![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ)

# cyberdojo/differ docker image

- The source for the [cyberdojo/differ](https://hub.docker.com/r/cyberdojo/differ/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- Diffs two sets of files.

- - - -
# API
  * [GET diff(id,old_files,new_files)](#get-diffidold_filesnew_files)
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
## GET diff(id,old_files,new_files)
Returns the diff of two sets of files.
- parameters
  * **id:String** for tracing, must be in [base58](https://github.com/cyber-dojo/runner/blob/master/src/base58.rb)
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
- returns
  * unchanged lines as type "same" using the line number from **new_files**
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
# build the image and run the tests
- Builds the runner-server image and an example runner-client image.
- Brings up a runner-server container and a runner-client container.
- Runs the runner-server's tests from inside a runner-server container.
- Runs the runner-client's tests from inside the runner-client container.

```text
$ ./pipe_build_up_test.sh

Building differ-server
Step 1/11 : FROM cyberdojo/rack-base
 ---> 53514ad27605
Step 2/11 : LABEL maintainer=jon@jaggersoft.com
 ---> Using cache
 ---> 94a6238b6740
Step 3/11 : RUN apk --update --upgrade --no-cache add git
 ---> Using cache
 ---> ae2df5fcacd8
Step 4/11 : WORKDIR /app
 ---> Using cache
 ---> 92f640964673
Step 5/11 : COPY . .
 ---> Using cache
 ---> 57b02f0aa705
Step 6/11 : RUN chown -R nobody:nogroup .
 ---> Using cache
 ---> 8b8844fc4a28
Step 7/11 : ARG SHA
 ---> Using cache
 ---> 2b0da7c52fca
Step 8/11 : ENV SHA=${SHA}
 ---> Using cache
 ---> a71c866c37df
Step 9/11 : EXPOSE 4567
 ---> Using cache
 ---> 0bd1d2b88d3b
Step 10/11 : USER nobody
 ---> Using cache
 ---> 4469a50e4ad5
Step 11/11 : CMD [ "./up.sh" ]
 ---> Using cache
 ---> fd47167c5b2c
Successfully built fd47167c5b2c
Successfully tagged cyberdojo/differ:latest

Building differ-client
Step 1/8 : FROM cyberdojo/rack-base
 ---> 53514ad27605
Step 2/8 : LABEL maintainer=jon@jaggersoft.com
 ---> Using cache
 ---> 94a6238b6740
Step 3/8 : WORKDIR /app
 ---> Using cache
 ---> f252d87f807d
Step 4/8 : COPY . .
 ---> Using cache
 ---> b73d4ae5c329
Step 5/8 : RUN chown -R nobody:nogroup .
 ---> Using cache
 ---> 3a93825ee815
Step 6/8 : EXPOSE 4568
 ---> Using cache
 ---> f085fedcb40d
Step 7/8 : USER nobody
 ---> Using cache
 ---> a2031dcd7573
Step 8/8 : CMD [ "./up.sh" ]
 ---> Using cache
 ---> 63b81c437063
Successfully built 63b81c437063
Successfully tagged cyberdojo/differ-client:latest

Creating network "differ_default" with the default driver
Creating test-differ-client ... done
Creating test-differ-server ... done
Waiting until test-differ-server is ready......OK
Checking test-differ-server started cleanly...OK

Run options: --seed 41098

# Running:

..................................................................................................................

Finished in 1.227648s, 92.8605 runs/s, 161.2840 assertions/s.

114 runs, 198 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/coverage. 996 / 996 LOC (100.0%) covered.
Coverage report copied to test_server/coverage/

                    tests |     114 !=     0 | true
                 failures |       0 ==     0 | true
                   errors |       0 ==     0 | true
                 warnings |       0 ==     0 | true
                    skips |       0 ==     0 | true
        duration(test)[s] |    0.84 <=     3 | true
         coverage(src)[%] |   100.0 ==   100 | true
        coverage(test)[%] |   100.0 ==   100 | true
   lines(test)/lines(src) |    2.64 >=   2.6 | true
     hits(src)/hits(test) |    5.49 >=   5.4 | true
Run options: --seed 32608

# Running:

...............................

Finished in 0.948768s, 32.6740 runs/s, 26.3500 assertions/s.

31 runs, 25 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/coverage. 196 / 196 LOC (100.0%) covered.
Coverage report copied to test_client/coverage/

                    tests |      31 !=     0 | true
                 failures |       0 ==     0 | true
                   errors |       0 ==     0 | true
                 warnings |       0 ==     0 | true
                    skips |       0 ==     0 | true
        duration(test)[s] |    0.95 <=     5 | true
         coverage(src)[%] |   100.0 ==   100 | true
        coverage(test)[%] |   100.0 ==   100 | true
   lines(test)/lines(src) |   11.25 >=    10 | true
     hits(src)/hits(test) |    1.77 >=   1.5 | true
------------------------------------------------------
All passed
Stopping test-differ-server ... done
Stopping test-differ-client ... done
Removing test-differ-server ... done
Removing test-differ-client ... done
Removing network differ_default
```

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

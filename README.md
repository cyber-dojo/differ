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
# build the image and run the tests
- Builds the differ-server image and an example differ-client image.
- Brings up a differ-server container and a differ-client container.
- Runs the differ-server's tests from inside a differ-server container.
- Runs the differ-client's tests from inside the differ-client container.

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
 ---> 5545d0b2821b
Step 6/11 : RUN chown -R nobody:nogroup .
 ---> Using cache
 ---> 5ffa81284eae
Step 7/11 : ARG SHA
 ---> Using cache
 ---> d3016a7a3559
Step 8/11 : ENV SHA=${SHA}
 ---> Using cache
 ---> 59cda155bb7a
Step 9/11 : EXPOSE 4567
 ---> Using cache
 ---> f82712f0363f
Step 10/11 : USER nobody
 ---> Using cache
 ---> 4fccb433f5cf
Step 11/11 : CMD [ "./up.sh" ]
 ---> Using cache
 ---> 5778397480f5
Successfully built 5778397480f5
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
 ---> 966fc4705c65
Step 5/8 : RUN chown -R nobody:nogroup .
 ---> Running in 92579dd61878
Removing intermediate container 92579dd61878
 ---> 9aec9c3428da
Step 6/8 : EXPOSE 4568
 ---> Running in e001aa558b1d
Removing intermediate container e001aa558b1d
 ---> 5349e7a52dd6
Step 7/8 : USER nobody
 ---> Running in 05b702a8ff0f
Removing intermediate container 05b702a8ff0f
 ---> 4923858c8870
Step 8/8 : CMD [ "./up.sh" ]
 ---> Running in 878b5e9f6723
Removing intermediate container 878b5e9f6723
 ---> b1d315243feb
Successfully built b1d315243feb
Successfully tagged cyberdojo/differ-client:latest

Recreating test-differ-server ... done
Recreating test-differ-client ... done
Waiting until test-differ-server is ready.......OK
Checking test-differ-server started cleanly...OK

Run options: --seed 18680

# Running:

.............................................................................

Finished in 1.861635s, 41.3615 runs/s, 143.4223 assertions/s.

77 runs, 267 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/coverage. 894 / 894 LOC (100.0%) covered.
Coverage report copied to test_server/coverage/

                    tests |      77 !=     0 | true
                 failures |       0 ==     0 | true
                   errors |       0 ==     0 | true
                 warnings |       0 ==     0 | true
                    skips |       0 ==     0 | true
        duration(test)[s] |    1.86 <=     3 | true
         coverage(src)[%] |   100.0 ==   100 | true
        coverage(test)[%] |   100.0 ==   100 | true
   lines(test)/lines(src) |    1.93 >=   1.9 | true
     hits(src)/hits(test) |   18.48 >=   2.9 | true
Run options: --seed 26666

# Running:

..................................

Finished in 0.946357s, 35.9273 runs/s, 76.0812 assertions/s.

34 runs, 72 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/coverage. 261 / 261 LOC (100.0%) covered.
Coverage report copied to test_client/coverage/

                    tests |      34 !=     0 | true
                 failures |       0 ==     0 | true
                   errors |       0 ==     0 | true
                 warnings |       0 ==     0 | true
                    skips |       0 ==     0 | true
        duration(test)[s] |    0.95 <=     5 | true
         coverage(src)[%] |   100.0 ==   100 | true
        coverage(test)[%] |   100.0 ==   100 | true
   lines(test)/lines(src) |    3.14 >=     3 | true
     hits(src)/hits(test) |    1.25 >=   1.2 | true
------------------------------------------------------
All passed
Stopping test-differ-client ... done
Stopping test-differ-server ... done
Removing test-differ-client ... done
Removing test-differ-server ... done
Removing network differ_default
```

- - - -
# build the demo and run it
- Runs inside the differ-client's container.
- Calls the differ-server's methods and displays their json results and how long they took.
- If the differ-client's IP address is 192.168.99.100 then put 192.168.99.100:4568 into your browser to see the output.

```bash
$ ./sh/run_demo.sh
```
![demo screenshot](test_client/src/demo_screenshot.png?raw=true "demo screenshot")

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

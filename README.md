
[Take me to the cyber-dojo home page](https://github.com/cyber-dojo/cyber-dojo).

- - - -

[![Build Status](https://travis-ci.org/cyber-dojo/differ.svg?branch=master)](https://travis-ci.org/cyber-dojo/differ)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/differ docker image

- A micro-service for [cyber-dojo](http://cyber-dojo.org).
- Diffs two sets of files.

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- - - -

## diff
Asks for the diff between two sets of files.
- parameters
  * was_files, eg
```
  { "hiker.h": "#ifndef HIKER_INCLUDED...",
    "hiker.c": "#include <stdio.h>...",
    "hiker.tests.c": "#include <assert.h>..."
    ...
  }
```
  * now_files, eg
```
  { "fizz_buzz.h": "#ifndef FIZZ_BUZZ_INCLUDED...",
    "hiker.c": "#include <stdio.h>...",
    "hiker.tests.c": "#include <assert.h>..."
    ...
  }
```

- - - -


```
./demo.sh
```

Creates two docker images; a diff-client and a diff-server (both using sinatra).
The diff-client sends two sets of files (in a json body) to the diff-server and the diff-server
returns their processed diff. The diff-client runs on port 4568 and the diff-server
on port 4567. If the diff-client's IP address is 192.168.99.100 then put
192.168.99.100:4568 into your browser to see the processed diff.

```
./pipe_build_up_test.sh
```

Rebuilds the images and runs the tests inside the
differ-server and differ-client containers.

...
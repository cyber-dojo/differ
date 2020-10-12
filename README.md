[![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ)

- The source for the [cyberdojo/differ](https://hub.docker.com/r/cyberdojo/differ/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An http service (rack based) for diffing two sets of files.

***
API

* [GET alive?](docs/api.md#get-alive)  
* [GET ready?](docs/api.md#get-ready)
* [GET sha](docs/api.md#get-sha)
* [GET diff(id,old_files,new_files)](docs/api.md#get-diffidold_filesnew_files)
* [GET diff_tip_data(id,old_files,new_files)](docs/api.md#get-diff_tip_dataidold_filesnew_files)

***

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

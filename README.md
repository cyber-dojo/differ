[![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ)

- The source for the [cyberdojo/differ](https://hub.docker.com/r/cyberdojo/differ/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An http service (sinatra based) for diffing two sets of files.

***
API

* [GET sha](docs/api.md#get-sha)
* [GET alive](docs/api.md#get-alive)  
* [GET healthy](docs/api.md#get-healthy)
* [GET ready](docs/api.md#get-ready)
* [GET diff_files(id,was_index,now_index)](docs/api.md#get-diff_filesidwas_indexnow_index)
* [GET diff_summary(id,was_index,now_index)](docs/api.md#get-diff_summaryidwas_indexnow_index)

***

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

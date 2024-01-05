[![Github Action (main)](https://github.com/cyber-dojo/differ/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/differ/actions)

- A [docker-containerized](https://registry.hub.docker.com/r/cyberdojo/differ) micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An HTTP service (sinatra based) for diffing two sets of files.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI pipeline](https://app.kosli.com/cyber-dojo/flows/differ/artifacts/) 
  deploying to [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) and [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environments.


***
API

* [GET sha](docs/api.md#get-sha)
* [GET alive](docs/api.md#get-alive)  
* [GET ready](docs/api.md#get-ready)
* [GET diff_files(id,was_index,now_index)](docs/api.md#get-diff_filesidwas_indexnow_index)
* [GET diff_summary(id,was_index,now_index)](docs/api.md#get-diff_summaryidwas_indexnow_index)

***

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

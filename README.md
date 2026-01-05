[![Github Action (main)](https://github.com/cyber-dojo/differ/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/differ/actions)

- A [docker-containerized](https://registry.hub.docker.com/r/cyberdojo/differ) micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An HTTP [Ruby](https://www.ruby-lang.org) [Sinatra](http://sinatrarb.com/) service for diffing two sets of files.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/differ-ci/trails/) 
  deploying, with Continuous Compliance, to its [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) AWS environment.
- Deployment to its [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environment is via a separate [promotion workflow](https://github.com/cyber-dojo/aws-prod-co-promotion).
- Uses Attestation patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

# Development

There are two sets of tests:
- server: these run from inside the differ container
- client: these run from outside the differ container, making api calls only 

```bash
# Build the images
$ make {image_server|image_client}

# Run all tests
$ make {test_server|test_client}

# Run only specific tests
$ ./bin/run_tests.sh {-h|--help}
$ ./bin/run_tests.sh {server|client} B56Sp3
$ make {test_server|test_client} tid=B56

# Check test metrics
$ make {metrics_test_server|metrics_test_client}

# Check test coverage metrics
$ make {metrics_coverage_server|metrics_coverage_client}

# Check image for snyk vulnerabilities
$ make snyk_container_test 

# Run demo
$ make demo
```

# API

* [GET alive](docs/api.md#get-alive)  
* [GET ready](docs/api.md#get-ready)
* [GET sha](docs/api.md#get-sha)
* [GET diff_lines(id,was_index,now_index)](docs/api.md#get-diff_linesidwas_indexnow_index)
* [GET diff_summary(id,was_index,now_index)](docs/api.md#get-diff_summaryidwas_indexnow_index)

# Screenshots

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

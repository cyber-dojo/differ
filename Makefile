
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/differ:${SHORT_SHA}

.PHONY: all image test_unit test_integration test_all coverage_unit coverage_integration coverage_all lint snyk-container demo

all: test_all coverage_all lint snyk-container

image:
	${PWD}/sh/build_image.sh


test_unit: image
	${PWD}/sh/run_tests.sh server

test_integration: image
	${PWD}/sh/run_tests.sh client

test_all: test_unit test_integration


coverage_unit:
	${PWD}/sh/run_coverage.sh server

coverage_integration:
	${PWD}/sh/run_coverage.sh client

coverage_all: coverage_unit coverage_integration


lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk-container: image
	snyk container test ${IMAGE_NAME} \
        --file=Dockerfile \
        --json-file-output=snyk.container.scan.json \
        --policy-path=.snyk

snyk-code:
	snyk code test \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json \
		.

demo: image
	${PWD}/sh/demo.sh

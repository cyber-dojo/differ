
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/differ:${SHORT_SHA}

.PHONY: test lint snyk image

test: image
	${PWD}/sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk: image
	snyk container test ${IMAGE_NAME}
        --file=Dockerfile
        --json-file-output=snyk.json
        --policy-path=.snyk

image:
	${PWD}/build_test.sh --build-only
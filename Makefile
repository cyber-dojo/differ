
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/differ:${SHORT_SHA}

.PHONY: all test lint snyk demo image

all: test lint snyk demo

test: image
	${PWD}/sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk: image
	snyk container test ${IMAGE_NAME}
        --file=Dockerfile
        --json-file-output=snyk.json
        --policy-path=.snyk

demo: image
	${PWD}/sh/demo.sh

image:
	${PWD}/sh/build_image.sh
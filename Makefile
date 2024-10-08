
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/differ:${SHORT_SHA}

.PHONY: all image test lint snyk-container demo

all: image test lint snyk-container demo

image:
	${PWD}/sh/build_image.sh

test: image
	${PWD}/sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk-container: image
	snyk container test ${IMAGE_NAME}
        --file=Dockerfile
        --json-file-output=snyk.container.scan.json
        --policy-path=.snyk

demo: image
	${PWD}/sh/demo.sh

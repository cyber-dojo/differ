
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)


.PHONY: test lint snyk build

test:
	${PWD}/sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk: build
	snyk container test cyberdojo/differ:${SHORT_SHA}
        --file=Dockerfile
        --json-file-output=snyk.json
        --policy-path=.snyk

build:
	${PWD}/build_test.sh --build-only
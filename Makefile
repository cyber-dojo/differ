
all_server: build_server test_server coverage_server

build_server:
	${PWD}/sh/build_image.sh server

# test_server does NOT depend on build_server, because in the CI workflow, the image is built with a GitHub Action
# If you want to run only some tests, locally, use run_tests.sh directly
test_server:
	${PWD}/sh/run_tests.sh server

coverage_server:
	${PWD}/sh/check_coverage.sh server


all_client: build_client test_client coverage_client

build_client:
	${PWD}/sh/build_image.sh client

test_client:
	${PWD}/sh/run_tests.sh client

coverage_client:
	${PWD}/sh/check_coverage.sh client


demo:
	${PWD}/sh/demo.sh


rubocop_lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error


snyk_container:
	snyk container test ${IMAGE_NAME} \
        --file=Dockerfile \
        --json-file-output=snyk.container.scan.json \
        --policy-path=.snyk


snyk_code:
	snyk code test \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json \
		.

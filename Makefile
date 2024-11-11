
all_server: image_server test_server metrics_test_server metrics_coverage_server

image_server:
	${PWD}/bin/build_image.sh server

# test_server does NOT depend on build_server, because in the CI workflow,
# the image is built with a GitHub Action.
# If you want to run only some tests, locally, use ./bin/run_tests.sh directly
test_server:
	${PWD}/bin/run_tests.sh server

metrics_test_server:
	@${PWD}/bin/check_test_metrics.sh server

metrics_coverage_server:
	@${PWD}/bin/check_coverage_metrics.sh server


all_client: test_client metrics_test_client metrics_coverage_client

image_client:
	${PWD}/bin/build_image.sh client

test_client: 
	${PWD}/bin/run_tests.sh client

metrics_test_client:
	@${PWD}/bin/check_test_metrics.sh client

metrics_coverage_client:
	@${PWD}/bin/check_coverage_metrics.sh client


demo:
	${PWD}/bin/demo.sh


rubocop_lint:
	@${PWD}/bin/rubocop_lint.sh


snyk_container_test:
	${PWD}/bin/snyk_container_test.sh


snyk_code:
	snyk code test \
		--policy-path=.snyk \
		--sarif \
		--sarif-file-output=snyk.code.scan.json \
		.

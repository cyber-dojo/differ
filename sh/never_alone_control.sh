#!/usr/bin/env bash
set -Eeu

# Spike script for https://github.com/kosli-dev/server/issues/2175
SCRIPT_NAME=never_alone_control.sh

PULL_REQUEST_JSON_FILE="pull-request-list.json"
MISSING_PULL_REQUESTS_FILE="failed-pull-requests.json"

function print_help
{
    cat <<EOF
Usage: $SCRIPT_NAME [options]

Script to parse get pull request info to check that all commits have pull-requests

Options are:
  -h          Print this help menu
EOF
}


function check_arguments
{
    while getopts "h" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
}

function check_for_pull_requests {
    local file=$1;shift
    local failed_reviews=()

    # Read each entry and check if it is missing latestReviews or if that list is empty
    while IFS= read -r entry; do
        latest_reviews=$(echo "$entry" | jq '.latestReviews // empty')
        if [ -z "$latest_reviews" ]; then
            failed_reviews+=("$entry")
        fi
    done < <(jq -c '.[]' "$file")

    echo "${failed_reviews[@]}" | jq  -s '.' > ${MISSING_PULL_REQUESTS_FILE}

    # Need to check if we have any failed or not and do a return or an echo with result
}


function main {
    check_arguments "$@"
    check_for_pull_requests ${PULL_REQUEST_JSON_FILE}
    # also correct return here
}

main "$@"

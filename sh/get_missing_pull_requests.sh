#!/usr/bin/env bash
set -Eeu

# Spike script for https://github.com/kosli-dev/server/issues/2175
SCRIPT_NAME=get_missing_pull_requests.sh

INPUT_FILE=""
OUTPUT_FILE="missing-pull-requests.json"


die()
{
    echo "Error: $1" >&2
    exit 1
}


function print_help
{
    cat <<EOF
Usage: $SCRIPT_NAME [options]

Script to parse pull request info file to check that all commits have pull-requests
The script is intended to run on the output of the `get_commits_with_pull_request_info.sh`
script

Options are:
  -h               Print this help menu
  -i <input-file>  Json input file
  -o <output-file> Output file. Default: ${OUTPUT_FILE}
EOF
}


function check_arguments
{
    while getopts "hi:o:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            i)
                INPUT_FILE=${OPTARG}
                ;;
            o)
                OUTPUT_JSON_FILE=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "${INPUT_FILE}" ]; then
        die "option -i <input-file> is mandatory"
    fi

}

function get_missing_pull_requests {
    local file=$1;shift
    local failed_reviews=()

    # Read each entry and check if it is missing latestReviews or if that list is empty
    while IFS= read -r entry; do
        latest_reviews=$(echo "$entry" | jq '.latestReviews // empty')
        if [ -z "$latest_reviews" ]; then
            failed_reviews+=("$entry")
        fi
    done < <(jq -c '.[]' "$file")

    echo "${failed_reviews[@]}" | jq  -s '.' > ${OUTPUT_FILE}
}


function main {
    check_arguments "$@"
    get_missing_pull_requests ${INPUT_FILE}
}

main "$@"

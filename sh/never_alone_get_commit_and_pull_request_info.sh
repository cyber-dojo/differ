#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=never_alone_get_commit_and_pull_reqeust_info.sh
OUTPUT_FILE=""
COMMIT_SHA=""


function print_help
{
    cat <<EOF
Use: $SCRIPT_NAME [options]

Script that gets commit and pull-request info for a commit sha

Options are:
  -h                   Print this help menu
  -c <commit-sha>      Commit sha. Required
  -o <output-file>     Result output file. Required
EOF
}


function die
{
    echo "Error: $1" >&2
    exit 1
}


function check_arguments
{
    while getopts "hc:o:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            c)
                COMMIT_SHA=${OPTARG}
                ;;
            o)
                OUTPUT_FILE=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "${COMMIT_SHA}" ]; then
        die "option -c <commit-sha> is required"
    fi
    if [ -z "${OUTPUT_FILE}" ]; then
        die "option -o <output-file> is required"
    fi
}


function get_commit_and_pull_request
{
    local commit_sha=$1; shift
    local result_file=$1; shift

    commit_data=$(gh search commits --hash "${commit_sha}" --json author)
    pr_data=$(gh pr list --search "${commit_sha}" --state merged --json author,latestReviews,mergeCommit,mergedAt,url)

    combined_data=$(jq -n --arg commitsha "$commit_sha" --argjson commit "$commit_data" --argjson pr "$pr_data" \
      '{commit_sha: $commitsha, commit: $commit[0], pull_request: $pr[0]}')

    echo "${combined_data}" > ${result_file}
}


function main
{
    check_arguments "$@"
    get_commit_and_pull_request ${COMMIT_SHA} ${OUTPUT_FILE}
}

main "$@"

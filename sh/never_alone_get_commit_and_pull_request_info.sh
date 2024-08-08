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

    # Use gh instead of git so we can keep the commit depth of 1. The order of the response for gh is reversed
    # so I do a tac at the end to get it the same order.
#    list_separator=""
#    echo "{" > ${result_file}

    commit_data=$(gh search commits --hash "${commit_sha}" --json author,sha)
    pr_data=$(gh pr list --search "${commit_sha}" --state merged --json author,latestReviews,mergeCommit,mergedAt,url)

#    if [ "$pr_data" = "[]" ]; then
#        # Commit is not merged back to master (this will happen if you run this on a branch)
#        echo '{"sha": "'${commit_sha}'"}' >> "${result_file}"
#    elif [ "$(echo "$pr_data" | jq '. | length')" -eq 0 ]; then
#        # No pull request found for that commit, so do a new request to get the commit
#        commit_data=$(gh search commits --hash "${commit_sha}" --json author,sha)
#        echo "$commit_data" | jq '.[0]' >> "${result_file}"
#    else
#        # The PR data does not contain the commit sha so we add it manually. Use 'sha' as key since that is
#        # what is used in the 'gh search commits' command
#        echo "$pr_data" | jq '{pullrequest: .[0]}' >> "${result_file}"
#    fi

    combined_data=$(jq -n --argjson commit "$commit_data" --argjson pr "$pr_data" '{commit: $commit[0], pullrequest: $pr[0]}')
    echo "${combined_data}" >> ${result_file}

}


function main
{
    check_arguments "$@"
    get_commit_and_pull_request ${COMMIT_SHA} ${OUTPUT_FILE}
}

main "$@"

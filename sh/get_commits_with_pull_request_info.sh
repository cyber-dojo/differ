#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=get_commits_with_pull_reqeust_info.sh

OUTPUT_FILE="pull-request-list.json"
BASE_COMMIT=""
PROPOSED_COMMIT=""


die()
{
    echo "Error: $1" >&2
    exit 1
}


function print_help
{
    cat <<EOF
Usage: $SCRIPT_NAME [options]

Script that gets all commits between base_commit and proposed_commit
and collects pull-request information about them. Store the result in a json-file.

Options are:
  -h                   Print this help menu
  -b <base_commit>     Oldest commit sha
  -p <proposed_commit> Newest commit sha
  -o <output file>     Result output file. Default: ${OUTPUT_FILE}
EOF
}


function check_arguments
{
    while getopts "hb:o:p:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            b)
                BASE_COMMIT=${OPTARG}
                ;;
            o)
                OUTPUT_FILE=${OPTARG}
                ;;
            p)
                PROPOSED_COMMIT=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "${BASE_COMMIT}" ]; then
        die "option -b <base_commit> is mandatory"
    fi
    if [ -z "${PROPOSED_COMMIT}" ]; then
        die "option -p <proposed_commit> is mandatory"
    fi
}


function get_pull_requests
{
    local base_commit=$1; shift
    local proposed_commit=$1; shift
    local result_file=$1; shift
    local commits list_separator
    commits=($(git rev-list --first-parent "${base_commit}..${proposed_commit}"))
    list_separator=""
    echo "[" > ${result_file}
    for commit in "${commits[@]}"; do
        echo "${list_separator}" >> ${result_file}
        pr_data=$(gh pr list --search "${commit}" --state merged --json author,latestReviews,mergeCommit,mergedAt,url)
        if [ "$(echo "$pr_data" | jq '. | length')" -eq 0 ]; then
            # No pull request found for that commit, so do a new request to get the commit
            commit_data=$(gh search commits --hash "${commit}" --json author,sha)
            echo "$commit_data" | jq '.[0]' >> "${result_file}"
        else
            # The PR data does not contain the commit sha so we add it manually. Use 'sha' as key since that is
            # what is used in the 'gh search commits' command
            echo "$pr_data" | jq --arg sha "$commit" '.[] | . + {sha: $sha}' >> "${result_file}"
        fi
        list_separator=","
    done
    echo "]" >> ${result_file}
}

function main {
    check_arguments "$@"
    get_pull_requests ${BASE_COMMIT} ${PROPOSED_COMMIT} ${OUTPUT_FILE}
}

main "$@"

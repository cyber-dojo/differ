#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=never_alone_report_commit_and_pr_to_kosli.sh
BASE_COMMIT=""
PROPOSED_COMMIT=""
FLOW_NAME=""


function print_help
{
    cat <<EOF
Use: $SCRIPT_NAME [options]

Script that gets commit and pull-request info for a commit sha

Options are:
  -h                   Print this help menu
  -b <base-commit>     Oldest commit sha. Required
  -p <proposed-commit> Newest commit sha. Required
  -f <flow-name>       Flow name to report commit and pull-request info. Required
EOF
}


function die
{
    echo "Error: $1" >&2
    exit 1
}


function check_arguments
{
    while getopts "hb:p:f:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            b)
                BASE_COMMIT=${OPTARG}
                ;;
            p)
                PROPOSED_COMMIT=${OPTARG}
                ;;
            f)
                FLOW_NAME=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "${BASE_COMMIT}" ]; then
        die "option -b <base-commit> is required"
    fi
    if [ -z "${PROPOSED_COMMIT}" ]; then
        die "option -p <proposed-commit> is required"
    fi
    if [ -z "${FLOW_NAME}" ]; then
        die "option -f <flow-name> is required"
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

function get_commit_and_pr_data_and_report_to_kosli
{
    local base_commit=$1; shift
    local proposed_commit=$1; shift
    local commit_pull_request_flow=$1; shift
    local trail_name=${proposed_commit}

    commits=($(gh api repos/:owner/:repo/compare/${base_commit}...${proposed_commit} -q '.commits[].sha'))
    for commit_sha in "${commits[@]}"; do
        short_commit_sha=${commit_sha:0:7}
        local file_name="commit_pr_${short_commit_sha}.json"
        get_commit_and_pull_request ${commit_sha} ${file_name}
        echo commit_sha=$commit_sha
        kosli attest generic \
            --name=commit_${short_commit_sha} \
            --compliant=true \
            --attachments="${file_name}" \
            --flow=${commit_pull_request_flow} \
            --trail=${trail_name} \
            --host="http://localhost" \
            --org=use-cases \
            --api-token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IlRvcmVNZXJrZWx5In0.Dm-d5pNxmy83B9H6534SPRqG7cXnDSQ5rYOd5SBxwM0"
    done
}



function main
{
    check_arguments "$@"

    get_commit_and_pr_data_and_report_to_kosli ${BASE_COMMIT} ${PROPOSED_COMMIT} ${FLOW_NAME}
}

main "$@"
#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=never_alone.sh
export ROOT_DIR="$(git rev-parse --show-toplevel)"
export SH_DIR="${ROOT_DIR}/sh"


MAIN_BRANCH="main"
RESULT_JSON_FILE="pull-request-list.json"


function print_help
{
    cat <<EOF
Usage: $SCRIPT_NAME [options]

Script to get pull request info for all commits to main/master branch

Options are:
  -h          Print this help menu
  -m <branch> Name of main/master branch. Default: ${MAIN_BRANCH}
EOF
}


function check_arguments
{
    while getopts "hm:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            m)
                MAIN_BRANCH=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done
}


function main {
    check_arguments "$@"

    local base_commit proposed_commit
    # proposed_commit: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
    # base_commit: the commit corresponding to the Artifact base_commitly running in KOSLI_ENVIRONMENT, that will be replaced
    base_commit=$(${SH_DIR}/get_commit_of_current_sw_running.sh -e ${KOSLI_ENVIRONMENT} -f ${KOSLI_FLOW})
    proposed_commit=$(git rev-parse ${MAIN_BRANCH})
    ${SH_DIR}/get_commits_with_pull_request_info.sh -b ${base_commit} -p ${proposed_commit} -o pull-request-list.json
    ${SH_DIR}/get_failing_pull_requests.sh -i pull-request-list.json -o missing-pull-requests.json
}

main "$@"

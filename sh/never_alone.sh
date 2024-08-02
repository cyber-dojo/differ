#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME="never_alone.sh"
MAIN_BRANCH=""
PULL_REQUEST_LIST_JSON_FILENAME=""
FAILED_PULL_REQUESTS_JSON_FILENAME=""


function print_help
{
    cat <<EOF
Use: $SCRIPT_NAME [options]

Script to get pull request info for all commits to main/master branch

Options are:
  -h                       Print this help menu
  -m <branch>              Name of main/master branch. Required
  -p <all-prs-filename>    Name of json file to save all pull-requests. Required
  -f <failed-prs-filename> Name of json file to save failed pull-requests: Required
EOF
}


function die
{
    echo "Error: $1" >&2
    exit 1
}


function repo_root
{
  git rev-parse --show-toplevel
}


function check_arguments
{
    while getopts "hm:p:f:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            m)
                MAIN_BRANCH=${OPTARG}
                ;;
            p)
                PULL_REQUEST_LIST_JSON_FILENAME=${OPTARG}
                ;;
            f)
                FAILED_PULL_REQUESTS_JSON_FILENAME=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "${MAIN_BRANCH}" ]; then
        die "option -m <branch> is required"
    fi
    if [ -z "${PULL_REQUEST_LIST_JSON_FILENAME}" ]; then
        die "option -p <all-prs-filename> is required"
    fi
    if [ -z "${FAILED_PULL_REQUESTS_JSON_FILENAME}" ]; then
        die "option -f <failed-prs-filename> is required"
    fi
}

function main
{
    check_arguments "$@"

    # base_commit: the commit corresponding to the Artifact currently running in KOSLI_ENVIRONMENT, that will be replaced
    local -r base_commit=$($(repo_root)/sh/never_alone_get_commit_of_current_sw_running.sh -e ${KOSLI_ENVIRONMENT} -f ${KOSLI_FLOW})
    # proposed_commit: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
    local -r proposed_commit=$(git rev-parse ${MAIN_BRANCH})

    $(repo_root)/sh/never_alone_get_commits_with_pull_request_info.sh -b ${base_commit} -p ${proposed_commit} -o ${PULL_REQUEST_LIST_JSON_FILENAME}
    $(repo_root)/sh/never_alone_get_failing_pull_requests.sh -i ${PULL_REQUEST_LIST_JSON_FILENAME} -o ${FAILED_PULL_REQUESTS_JSON_FILENAME}
}

main "$@"

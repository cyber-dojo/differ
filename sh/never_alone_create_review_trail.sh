#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME="never_alone_create_review_trail.sh"
MAIN_BRANCH=""
COMMIT_PULL_REQUEST_FLOW=""


function print_help
{
    cat <<EOF
Use: $SCRIPT_NAME [options]

Script to get commit and pull request info for all commits to main/master branch
and report them to Kosli

Options are:
  -h             Print this help menu
  -m <branch>    Name of main/master branch. Required
  -f <flow>      Name of kosli flow to report commit and pull request info to. Required
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
    while getopts "hm:f:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            m)
                MAIN_BRANCH=${OPTARG}
                ;;
            f)
                COMMIT_PULL_REQUEST_FLOW=${OPTARG}
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
    if [ -z "${COMMIT_PULL_REQUEST_FLOW}" ]; then
        die "option -f <commit-prs-filename> is required"
    fi
}

function begin_trail
{
    local commit_pull_request_flow=$1; shift
    local trail_name=$1; shift

    kosli begin trail ${trail_name} \
        --flow=${commit_pull_request_flow}
}


function main
{
    check_arguments "$@"
    # base_commit: the commit corresponding to the Artifact currently running in KOSLI_ENVIRONMENT, that will be replaced
    local base_commit=$($(repo_root)/sh/never_alone_get_commit_of_current_sw_running.sh -e ${KOSLI_ENVIRONMENT} -f ${KOSLI_FLOW})
    # proposed_commit: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
    local proposed_commit=$(git rev-parse ${MAIN_BRANCH})

    local trail_name=${proposed_commit}
    begin_trail ${COMMIT_PULL_REQUEST_FLOW} ${trail_name}
    $(repo_root)/sh/never_alone_report_commit_and_pr_to_kosli.sh \
        -b ${base_commit} \
        -p ${proposed_commit} \
        -f ${COMMIT_PULL_REQUEST_FLOW} \
        -t ${trail_name}
}

main "$@"

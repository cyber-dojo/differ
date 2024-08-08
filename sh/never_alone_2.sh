#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME="never_alone_2.sh"
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

function begin_trail {
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

    base_commit=45739b0c6f63f672c150e8265a60269a9d938b77
    proposed_commit=111c12f7f7abee3b78640a64a63d31bc0cdb5ab9
#    base_commit=910dbb5a7a52922788a0cb1e0b000b46a47ab25b
#    proposed_commit=e8db40dbd52737b2786d02a857f734a920af4874

    local trail_name=${proposed_commit:0:7}-reviews
    begin_trail ${COMMIT_PULL_REQUEST_FLOW} ${trail_name}
    $(repo_root)/sh/never_alone_report_commit_and_pr_to_kosli.sh \
        -b ${base_commit} \
        -p ${proposed_commit} \
        -f ${COMMIT_PULL_REQUEST_FLOW} \
        -t ${trail_name}
}

main "$@"

#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=never_alone_get_commit_of_current_sw_running.sh
KOSLI_ENVIRONMENT=""
KOSLI_FLOW=""


function print_help
{
    cat <<EOF
Use: $SCRIPT_NAME [options]

Script to get git commit for currently running SW in an environment

Options are:
  -h               Print this help menu
  -e <environment> Name of kosli environment to get current SW from. Required
  -f <flow>        Name of kosli flow the current SW artifact is coming from. Required
EOF
}


function die
{
    echo "Error: $1" >&2
    exit 1
}


function check_arguments
{
    while getopts "he:f:" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            e)
                KOSLI_ENVIRONMENT=${OPTARG}
                ;;
            f)
                KOSLI_FLOW=${OPTARG}
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "${KOSLI_ENVIRONMENT}" ]; then
        die "option -e <environment> is required"
    fi
    if [ -z "${KOSLI_FLOW}" ]; then
        die "option -f <flow> is required"
    fi
}


function get_current_sw_running
{
    local kosli_environment=$1; shift
    local kosli_flow=$1; shift
    local -r snapshot_json_filename=/tmp/snapshot.json

    # Use Kosli CLI to get info on what artifacts are currently running in the given environment
    kosli get snapshot "${kosli_environment}" --output=json > "${snapshot_json_filename}"

    artifacts_length=$(jq '.artifacts | length' ${snapshot_json_filename})
    for i in $(seq 0 $(( artifacts_length - 1 )))
    do
        annotation_type=$(jq -r ".artifacts[$i].annotation.type" ${snapshot_json_filename})
        if [ "${annotation_type}" != "exited" ] ; then
          flow=$(jq -r ".artifacts[$i].flow_name" ${snapshot_json_filename})
          if [ "${flow}" == "${kosli_flow}" ] ; then
            git_commit=$(jq -r ".artifacts[$i].git_commit" ${snapshot_json_filename})
            echo "${git_commit}"
            return
          fi
        fi
    done
}


function main
{
    check_arguments "$@"
    get_current_sw_running ${KOSLI_ENVIRONMENT} ${KOSLI_FLOW}
}

main "$@"

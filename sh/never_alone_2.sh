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
    local trail_name=$1; shift
    local commit_pull_request_flow=$1; shift

    kosli begin trail ${trail_name} \
        --flow=${commit_pull_request_flow} \
        --host="http://localhost" \
        --org=use-cases \
        --api-token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IlRvcmVNZXJrZWx5In0.Dm-d5pNxmy83B9H6534SPRqG7cXnDSQ5rYOd5SBxwM0"
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
        $(repo_root)/sh/never_alone_get_commit_and_pull_request_info.sh -c ${commit_sha} -o ${file_name}
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
    # base_commit: the commit corresponding to the Artifact currently running in KOSLI_ENVIRONMENT, that will be replaced
    local base_commit=$($(repo_root)/sh/never_alone_get_commit_of_current_sw_running.sh -e ${KOSLI_ENVIRONMENT} -f ${KOSLI_FLOW})
    # proposed_commit: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
    local proposed_commit=$(git rev-parse ${MAIN_BRANCH})
    base_commit=30f5f9e60c686caa1f347b39d48553f76d95368b
    proposed_commit=efd1349fcafd75170226eded789a3f1877245211
    begin_trail ${proposed_commit} ${COMMIT_PULL_REQUEST_FLOW}
    get_commit_and_pr_data_and_report_to_kosli ${base_commit} ${proposed_commit} ${COMMIT_PULL_REQUEST_FLOW}
}

main "$@"

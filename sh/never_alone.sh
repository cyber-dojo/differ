#!/usr/bin/env bash
set -Eeu

# Spike script for https://github.com/kosli-dev/server/issues/2175
SCRIPT_NAME=never_alone.sh

export KOSLI_ORG="${KOSLI_ORG:-cyber-dojo}"                       # wip default
export KOSLI_API_TOKEN="${KOSLI_API_TOKEN:-80rtyg24o0fgh0we8fh}"  # wip default=fake read-only token
export KOSLI_ENVIRONMENT="${KOSLI_ENVIRONMENT:-aws-prod}"         # wip default
export KOSLI_FLOW="${KOSLI_FLOW:-differ-ci}"               # wip default
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
    while getopts "he:m:" opt; do
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
        echo "commit=${commit}"
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

    local base_commit proposed_commit
    # proposed_commit: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
    # base_commit: the commit corresponding to the Artifact base_commitly running in KOSLI_ENVIRONMENT, that will be replaced
    base_commit=$(get_current_sw_running ${KOSLI_ENVIRONMENT} ${KOSLI_FLOW})
    proposed_commit=$(git rev-parse ${MAIN_BRANCH})

    # base_commit=f4215fc5060e6e7c60b32be05b657929a271efcc   # wip (2 deploys back, because on main, proposed_commit==base_commit)

    # Examples on kosli server with a mix of pull requests and not
    base_commit="5174289eb400fa46cca7d714433fdb45fb71ddb8"
    proposed_commit="ace68ab699b6b7c2f683b63a49671ba685002109"
    get_pull_requests ${base_commit} ${proposed_commit} ${RESULT_JSON_FILE}
}

main "$@"


# proposed_commit: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
# base_commit: the commit corresponding to the Artifact currently running in KOSLI_ENVIRONMENT, that will be replaced
#proposed_commit=$(git rev-parse ${MAIN_BRANCH})
#base_commit=$(get_current)
#base_commit=f4215fc5060e6e7c60b32be05b657929a271efcc   # wip (2 deploys back, because on main, proposed_commit==base_commit)
#base_commit="5513ce31fcb4236ed2511470da39297c33b41b86"



#gh pr list --search "a96283918944a53b70175ce9605984f4e9e05630" --state merged --json assignees --json author --json mergedBy --json state
#commit=5985cdd8870f8d1b6a9223e61adc5f7ed44450e3
#gh pr list --search ${commit} --state merged --json author,latestReviews,url | jq --arg sha ${commit} 'map({($sha): .}) | add'
# x="a96283918944a53b70175ce9605984f4e9e05630"

# function pr_for_sha {
#   # http://joey.aghion.com/find-the-github-pull-request-for-a-commit/
#   # This appears not to work because `git log` stays on the current branch unless you use the --all flag.
#   git log --merges --ancestry-path --oneline ${x}..main
#   # This might be closer
#   git log --merges --ancestry-path --oneline ${x}..
# }
# pr_for_sha



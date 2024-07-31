#!/usr/bin/env bash
set -Eeu

# Spike script for https://github.com/kosli-dev/server/issues/2175

KOSLI_ORG="${KOSLI_ORG:-cyber-dojo}"                       # wip default
KOSLI_API_TOKEN="${KOSLI_API_TOKEN:-80rtyg24o0fgh0we8fh}"  # wip default=fake read-only token
KOSLI_ENVIRONMENT="${KOSLI_ENVIRONMENT:-aws-prod}"         # wip default
KOSLI_FLOW="${KOSLI_FLOW:-differ-ci}"               # wip default
MAIN_BRANCH="${MAIN_BRANCH:-main}"

function get_current
{
    local -r snapshot_json_filename=/tmp/snapshot.json

    # Use Kosli CLI to get info on what artifacts are currently running in the given environment
    kosli get snapshot "${KOSLI_ENVIRONMENT}" --output=json > "${snapshot_json_filename}"

    artifacts_length=$(jq '.artifacts | length' ${snapshot_json_filename})
    for i in $(seq 0 $(( artifacts_length - 1 )))
    do
        annotation_type=$(jq -r ".artifacts[$i].annotation.type" ${snapshot_json_filename})
        if [ "${annotation_type}" != "exited" ] ; then
          flow=$(jq -r ".artifacts[$i].flow_name" ${snapshot_json_filename})
          if [ "${flow}" == "${KOSLI_FLOW}" ] ; then
            git_commit=$(jq -r ".artifacts[$i].git_commit" ${snapshot_json_filename})
            echo "${git_commit}"
            return
          fi
        fi
    done
}

# proposed: the commit corresponding to the Trail for the live workflow, which is building an Artifact to be deployed
# current: the commit corresponding to the Artifact currently running in KOSLI_ENVIRONMENT, that will be replaced
proposed=$(git rev-parse ${MAIN_BRANCH})
current=$(get_current)
#current=f4215fc5060e6e7c60b32be05b657929a271efcc   # wip (2 deploys back, because on main, proposed==currently)

# shellcheck disable=SC2155
declare -A commits=$(git rev-list --first-parent "${current}..${proposed}")

for commit in "${commits[@]}"; do
  echo "${commit}"
  # TODO: get author + committer info for each
done



#gh pr list --search "a96283918944a53b70175ce9605984f4e9e05630" --state merged --json assignees --json author --json mergedBy --json state

# x="a96283918944a53b70175ce9605984f4e9e05630"

# function pr_for_sha {
#   # http://joey.aghion.com/find-the-github-pull-request-for-a-commit/
#   # This appears not to work because `git log` stays on the current branch unless you use the --all flag.
#   git log --merges --ancestry-path --oneline ${x}..main
#   # This might be closer
#   git log --merges --ancestry-path --oneline ${x}..
# }
# pr_for_sha



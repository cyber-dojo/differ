#!/usr/bin/env bash
set -Eeu


KOSLI_ENVIRONMENT=aws-prod

function get_previous {
    local -r snapshot_json_filename=snapshot.json

    # Use Kosli CLI to get info on what artifacts are currently running in the given environment
    # (docs/snapshot.json contains an example json file)
    kosli get snapshot "${KOSLI_ENVIRONMENT}" \
      --org="cyber-dojo" \
      --api-token="80rtyg24o0fgh0we8fh" \
      --output=json > "${snapshot_json_filename}" 

    artifacts_length=$(jq '.artifacts | length' ${snapshot_json_filename})
    for i in $(seq 0 $(( ${artifacts_length} - 1 )))
    do
        annotation_type=$(jq -r ".artifacts[$i].annotation.type" ${snapshot_json_filename})
        if [ "${annotation_type}" != "exited" ] ; then
          flow=$(jq -r ".artifacts[$i].flow_name" ${snapshot_json_filename})
          if [ "${flow}" == "differ-ci" ] ; then
            git_commit=$(jq -r ".artifacts[$i].git_commit" ${snapshot_json_filename})
            echo $git_commit
            return
          fi
        fi
    done
}

current=a96283918944a53b70175ce9605984f4e9e05630
previous=f4215fc5060e6e7c60b32be05b657929a271efcc
#previous=$(get_previous)
#echo $previous

declare -A commits=$(git rev-list --first-parent ${previous}..${current})

for commit in ${commits[@]}; do
  echo $commit
done


#gh pr list --search "a96283918944a53b70175ce9605984f4e9e05630" --state merged --json assignees --json author --json mergedBy --json state

# export GITHUB_UPSTREAM=differ
# x="a96283918944a53b70175ce9605984f4e9e05630"

# function pr_for_sha {
#   git log --merges --ancestry-path --oneline ${x}..main
# }

# pr_for_sha

#| grep 'pull request' | tail -n1 | awk '{print $5}' | cut -c2- | xargs -I % open https://github.com/$GITHUB_UPSTREAM/${PWD##*/}/pull/%


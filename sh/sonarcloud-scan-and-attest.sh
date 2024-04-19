#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
sha="$(cd "$(repo_root)" && git rev-parse HEAD)"
OWNER="${KOSLI_ORG}"
REPO="${SERVICE_NAME}"

get_checks_json()
{
    curl --request GET \
    --url "https://sonarcloud.io/api/measures/component?metricKeys=alert_status%2Cquality_gate_details%2Cbugs%2Csecurity_issues%2Ccode_smells%2Ccomplexity%2Cmaintainability_issues%2Creliability_issues%2Ccoverage&component=${OWNER}_${REPO}"  \
    --header "Authorization: ${SONARCLOUD_TOKEN}"
}

parse_json() {
    json_filename=results.json
    get_checks_json | jq '.' > ${json_filename}
    measures=$(jq -r '.component.measures' ${json_filename})
    measures_length=$(jq '.component.measures | length' ${json_filename})

    for i in $(seq 0 $(( ${measures_length} - 1 ))); do
        metric=$(jq -r ".component.measures[$i].metric" ${json_filename})
        if ([ ${metric} = "alert_status" ]); then
            success=$(jq -r ".component.measures[$i].value" ${json_filename})
            break
        fi
    done

    url="https://sonarcloud.io/project/overview?id=${OWNER}_${REPO}"

    KOSLI_COMPLIANT=$([ ${success} = "OK" ] && echo "true" || echo "false")
}

attest_to_kosli_generic() {
    kosli attest generic \
        --attachments="${json_filename}" \
        --compliant="${KOSLI_COMPLIANT}" \
        --name="${REPO}.sonarcloud-scan" \
        --external-url="sonarcloud-code-analysis=${url}"
}

remove_json() {
    rm ${json_filename}
}

parse_json
attest_to_kosli_generic
remove_json

#!/usr/bin/env bash
set -Eeu

readonly OWNER="${KOSLI_ORG}"    # KOSLI_ORG is set in the CI workflow
readonly REPO="${SERVICE_NAME}"  # SERVICE_NAME is set in the CI workflow
readonly JSON_FILENAME=results.json

get_checks_json()
{
    curl \
      --header "Authorization: ${SONARCLOUD_TOKEN}" \
      --request GET \
      --url "https://sonarcloud.io/api/measures/component?metricKeys=alert_status%2Cquality_gate_details%2Cbugs%2Csecurity_issues%2Ccode_smells%2Ccomplexity%2Cmaintainability_issues%2Creliability_issues%2Ccoverage&component=${OWNER}_${REPO}"
}

parse_json()
{
    local success metric
    get_checks_json | jq '.' > "${JSON_FILENAME}"
    local -r measures_length=$(jq '.component.measures | length' "${JSON_FILENAME}")

    success=""
    for i in $(seq 0 $(( measures_length - 1 ))); do
        metric=$(jq -r ".component.measures[$i].metric" "${JSON_FILENAME}")
        if [ "${metric}" = "alert_status" ] ; then
            success=$(jq -r ".component.measures[$i].value" "${JSON_FILENAME}")
            break
        fi
    done

    KOSLI_COMPLIANT=$([ "${success}" = "OK" ] && echo "true" || echo "false")
}

attest_to_kosli_generic()
{
    # Relies CI workflow setting KOSLI_FLOW, KOSLI_TRAIL, KOSLI_FINGERPRINT env-vars.
    local -r url="https://sonarcloud.io/project/overview?id=${OWNER}_${REPO}"
    kosli attest generic \
        --attachments="${JSON_FILENAME}" \
        --compliant="${KOSLI_COMPLIANT}" \
        --name="${REPO}.sonarcloud-scan" \
        --external-url="sonarcloud-code-analysis=${url}"
}

remove_json()
{
    rm "${JSON_FILENAME}"
}

parse_json
attest_to_kosli_generic
remove_json

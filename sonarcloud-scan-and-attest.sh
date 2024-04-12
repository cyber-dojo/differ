#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
sha="$(cd "$(repo_root)" && git rev-parse HEAD)"
OWNER="${KOSLI_ORG}"
REPO="${SERVICE_NAME}"

get_checks_json()
{
    gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /repos/${OWNER}/${REPO}/commits/${sha}/check-runs?app_id=12526
}

parse_json() {
    json_filename=check-runs.json
    get_checks_json | jq '.check_runs.[0]' > ${json_filename}
    success=$(jq -r '.conclusion' ${json_filename})

    # URL to the scan analysis results on Github
    # Sonarcloud only seems to show the most recent results and I 
    # can't find a way to show results from previous scans,
    # so the Github URL seems the best way to access the results of the 
    # scan relevant to the commit
    url=$(jq -r '.html_url' ${json_filename})

    KOSLI_COMPLIANT=$([ ${success} = "success" ] && echo "true" || echo "false")
}

attest_to_kosli_generic() {
    kosli attest generic \
        --attachments="${json_filename}" \
        --compliant="${KOSLI_COMPLIANT}" \
        --name="${OWNER}.sonarcloud" \
        --dry-run \
        --external-url="sonarcloud-code-analysis=${url}" \
}

get_checks_json
parse_json
attest_to_kosli_generic


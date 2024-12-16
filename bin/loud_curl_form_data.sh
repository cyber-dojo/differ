#!/usr/bin/env bash
set -Eeu


loud_curl_form_data()
{
  # curl that prints the server traceback if the response
  # status code is not in the range 200-299
  local -r METHOD="${1}"  # eg GET/POST
  local -r URL="${2}"
  local -r API_TOKEN="${3}"
  local -r JSON_PAYLOAD="${4}"

  # Build curl form arguments
  CURL_FORM_ARGS=("--form" "data_json=${JSON_PAYLOAD}")

  HTTP_CODE=$(curl --header 'Content-Type: multipart/form-data' \
       --user "${API_TOKEN}:unused" \
       --write-out "%{http_code}" \
       --request "${METHOD}" \
       "${CURL_FORM_ARGS[@]}" \
       ${URL})
  set -e
  echo -n .
  if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]] ; then
      exit 22
  fi
}

loud_curl_form_data "$@"



# Report-Artifact

## Flows V1
```yml
kosli report artifact ...
   --git-commit=...
```

## Flows V2
```yml
kosli attest artifact ...
   --commit=...
```

## Differences
s/--git-commit/commit/


# Pull-Request

## Flows v1

```yml
kosli report evidence commit pullrequest github
    --flows="${{ env.KOSLI_FLOW }}"
    --github-token ${{ secrets.GITHUB_TOKEN }}
    --name=pull-request
```

## Flows v2

```yml
kosli attest pullrequest github
    --github-token ${{ secrets.GITHUB_TOKEN }}
    --name=pull-request
    --trail="${GITHUB_SHA}"
```

## Differences

- s/report evidence commit/attest/
- s/--flows//
- s//--trail=.../


# Report Generic

## Flows v1

```yml
kosli report evidence artifact generic "${IMAGE_NAME}" \
    --artifact-type=docker \
    --compliant=${KOSLI_COMPLIANT} \
    --description="server & client branch-coverage" \
    --name=branch-coverage \
    --user-data=./test/reports/evidence.json
```

## Flows v2

```yml
kosli attest generic "${IMAGE_NAME}" \
    --artifact-type=docker \
    --compliant=${KOSLI_COMPLIANT} \
    --description="server & client branch-coverage" \
    --attachments=./test/reports/evidence.json \
    --name=differ.branch-coverage \
    --trail="${GITHUB_SHA}"
```

## Differences

- s/report evidence artifact/attest/
- s/--name=branch-coverage/--name=differ.branch-coverage/
- s//--trail=.../


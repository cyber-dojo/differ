
# Workflows 

## main.yml 
Reports to https://app.kosli.com
The workflow to look in if you want to learn about Kosli.

## deploy-manually-to-aws-beta-and-aws-prod.yml 

For doing a real-life "emergency" roll-back to a previous image.

## deploy-manually-to-aws-beta.yml 

Deliberately run a non-compliant (but functional) artifact to https://beta.cyber-dojo.org for demo purposes.
This will create a new red snapshot.

### An image with provenance that is non-compliant 
Use the short-sha 38f3dc8 
This is the tag/commit of a differ image that failed its snyk-scan.
See https://app.kosli.com/cyber-dojo/flows/differ-ci/trails/38f3dc8b63abb632ac94a12b3f818b49f8047fa1
See https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/4352?fingerprint=a365bf5141a02231470539a5e52470e9530c0c13f73dc1653bb2ea6165beb2db

### An image with no provenance
Use the short-sha badhaxr
This is a specially prepared image tag.
TODO: A new image with this tag needs to be pushed to the ECR registry (was on dockerhub)
Its fingerprint is 388f48140331636dcb230bd8fd896c36e6007cc10c6065ad86a5bda61fe4a110
Eg https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/1465?active_tab=running

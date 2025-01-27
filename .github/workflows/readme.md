
# Workflows 

## commit_trigger.yml
Calls main.yml when there is a pushed commit.

## base_image_update.yml
A manually triggered workflow for updating the base-image in Dockerfile's `FROM ${BASE_IMAGE}`
Calls main.yml

## main.yml 
Reports to https://app.kosli.com  
The workflow to look in if you want to learn about Kosli.

## deploy-manually-to-aws-beta-and-aws-prod.yml 
For doing a real-life "emergency" roll-back to a previous image.

## deploy-manually-to-aws-beta.yml 
Deliberately run a non-compliant (but functional) artifact to https://beta.cyber-dojo.org for demo purposes.  
This will create a new non-compliant snapshot in the Kosli aws-beta Environment.

### An image with provenance that is non-compliant 
Use the short-sha `38f3dc8`   
This is the tag/commit of a differ image that failed its snyk-scan.  
See [example in snapshot](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/4352?fingerprint=a365bf5141a02231470539a5e52470e9530c0c13f73dc1653bb2ea6165beb2db)  
See [example in trail](https://app.kosli.com/cyber-dojo/flows/differ-ci/trails/38f3dc8b63abb632ac94a12b3f818b49f8047fa1)  

### An image with no provenance
Use the short-sha `badhaxr`  
This is a specially prepared image tag.  
Its fingerprint is 388f48140331636dcb230bd8fd896c36e6007cc10c6065ad86a5bda61fe4a110  
See [example in snapshot](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/4457?active_tab=running&fingerprint=388f48140331636dcb230bd8fd896c36e6007cc10c6065ad86a5bda61fe4a110)


# Workflows 

## main.yml 
main.yml runs when there is a pushed commit.
Reports to https://app.kosli.com  
The workflow to look in if you want to learn about [Kosli](https://kosli.com).
The main structure in this workflow is:
- The build-image job calls a [reusable-workflow](https://github.com/cyber-dojo/reusable-actions-workflows) which:
  - builds the image
  - pushes it to its private registry
  - saves the image as a tar file
  - pushes the tar file to the Github Action cache
  - returns the image fingerprint/digest
- Subsequent jobs do **not** build the image
  - They load it from the Github Action cache using [cyber-dojo/download-artifact@main](https://github.com/cyber-dojo/download-artifact)
  - The kosli-attest commands use the fingerprint returned from the build-image job


## deploy-manually-to-aws-beta.yml 
Deliberately run a non-compliant (but functional) artifact to https://beta.cyber-dojo.org for Kosli demo purposes.  
This will create a new non-compliant snapshot in the [Kosli aws-beta Environment](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/)

### An image with provenance that is non-compliant 
Use the short-sha `38f3dc8`   
This is the tag/commit of a differ image that failed its snyk-scan. 
Its fingerprint is a365bf5141a02231470539a5e52470e9530c0c13f73dc1653bb2ea6165beb2db  
See [example in snapshot](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/4352?fingerprint=a365bf5141a02231470539a5e52470e9530c0c13f73dc1653bb2ea6165beb2db)  
See [example in trail](https://app.kosli.com/cyber-dojo/flows/differ-ci/trails/38f3dc8b63abb632ac94a12b3f818b49f8047fa1)  

### An image with no provenance
Use the short-sha `badhaxr`  
This is a specially prepared image tag.  
Its fingerprint is 388f48140331636dcb230bd8fd896c36e6007cc10c6065ad86a5bda61fe4a110  
See [example in snapshot](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/4457?active_tab=running&fingerprint=388f48140331636dcb230bd8fd896c36e6007cc10c6065ad86a5bda61fe4a110)

## deploy-manually-to-aws-prod.yml 
For doing a real-life "emergency" roll-back to a previous image.


# main.yml 
Reports to https://app.kosli.com
The workflow to look in if you want to learn about Kosli.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

deploy-manually-to-aws-beta-and-aws-prod.yml is a manually triggered pipeline, which has two purposes:
1) in case you want to do a real-life "emergency" roll-back to a previous image
2) to deliberately run a non-compliant artifact in the cyber-dojo aws-beta and aws-prod 
   environments for demo purposes. In this case, please try to ensure you pick an
   image_tag that still works, since it will be deployed to https://cyber-dojo.org

   The simplest way to ensure this, is to pick an image that failed only its
   snyk-scan. For example 38f3dc8 (See https://app.kosli.com/cyber-dojo/flows/differ-ci/trails/38f3dc8b63abb632ac94a12b3f818b49f8047fa1)
   This will create a snapshot where differ has provenance, but is non-compliant.
   Eg https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/1461?active_tab=running
  
   Alternatively, you can pick an image_tag that is completely unknown to Kosli.
   There is a specially prepared image tag for this (that has been pushed to dockerhub).
   Its short-sha is badhaxr 
   Its fingerprint is 388f48140331636dcb230bd8fd896c36e6007cc10c6065ad86a5bda61fe4a110
   This will result in Kosli snapshot with an Artifact with no-provenance.
   Again, this Artifact will be deployed to https://cyber-dojo.org
   but this Artifact has full and correct functionality.
   Eg https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/1465?active_tab=running


Note: the lint: job very occasionally fails its CI job. 
This is typically a spurious failure, and if you re-run the failed jobs it will usually pass.

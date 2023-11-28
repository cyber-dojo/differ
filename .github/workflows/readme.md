
When showing CI workflows in Kosli demos, there is a tension created
by the fact that cyber-dojo Flows are unusual in that they need to 
repeat every Kosli step twice; once to report to https://staging.app.kosli.com
and once again to report to https://app.kosli.com
A normal customer CI workflow yml file would only report to the latter.
To resolve this, a git push triggers two workflows:

1) main.yml which reports to https://app.kosli.com
2) main_staging.yml which reports to https://staging.app.kosli.com
   This is basically the same as main.yml but it does NOT
   - rebuild the docker image (since the build is not binary reproducible)
   - deploy the image to aws-beta/aws-prod (since main.yml already does that)
    
During a demo, look at main.yml (and its three job_* yml files)
which is the workflow visible by default.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

deploy-manually.yml is a third, manually triggered pipeline, which has two purposes:
1) in case you want to do a real-life "emergency" roll-back to a previous image
2) to deliberately run a non-compliant artifact in the cyber-dojo aws-beta and aws-prod 
   environments for demo purposes. In this case, please try to ensure you pick an
   image_tag that still works, since it will be deployed to https://cyber-dojo.org
   The simplest way to ensure this, is to pick an image that failed only its
   snyk-scan. For example e091a4d (See https://app.kosli.com/cyber-dojo/flows/differ/artifacts/fb96934)

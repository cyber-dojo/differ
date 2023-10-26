
When showing CI workflows in Kosli demos, there is a tension created
by the fact that cyber-dojo Flows are unusual in that they need to 
repeat every Kosli step twice; once to report to https://staging.app.kosli.com
and once again to report to https://app.kosli.com
A normal customer CI workflow yml file would only report to the latter.
To resolve this git pushes triggers two workflows;

1) main.yml which reports to https://app.kosli.com
   - builds the image
       using build_image.yml
   - runs the tests  
       using test.yml
   - deploys the image to aws-beta and aws-prod
       using deploy.yml
   
2) main_staging.yml which reports to https://staging.app.kosli.com
   - waits for main.yml to build the image
   - tests the image
   - does _not_ deploy the image

During a demo, look at main.yml and its three helper yml files. 

# Demo Instructions

## Overview
This demo walks through how to show the ansible golden path.  Its broadly split into three sections:
1. Initial creation of a playbook, its associated artefacts, including pipelines, AAP setup, git repos etc
2. Demonstration of how inner loop development would work with a hosted development environment
3. Path to production - pipelines building, testing and pushing changes to AAP, and also the ability to promote content to a production project

## Demo Setup
Prior to running the demo, you will need the OCP admin password, and the AAP admin password to hand.  You can look them up during the demo, but normally its easier if you have them in a temproary text file somewhere for the duration of the demo.

## Initial Creation
1. Log into the OCP console, go to the backstage namespace, and find the route to Red Hat Developer Hub (RHDH).  
![backstage-route](./demo-images/1-backstage-route.png)
2. This should take you to the back stage signin page - where you want to click on OIDC.  
![backstage-signin](./demo-images/2-backstage-signin.png)
3. Then on the keycloak login, click on the gitlab button.  
![keycloak-login](./demo-images/3-keycloak-login.png)
4. The finally on the gitlab buttonm login as user1/Developerhub123! and accept any warnings.  
![gitlab-login](./demo-images/4-gitlab-login.png)
5. You should now see the DeveloperHub home page.  
![gitlab-login](./demo-images/5-gitlab-login.png)
6. Navigate to the golden templates by either clicking on the + sign on the top toolbar, or navigate to ansible in the menu on the left, and the the create menu button.  
![ansible-goldenpaths](./demo-images/6-ansible-goldenpaths.png)
7. Click on the tile to create a UKI playbook, and then fill in the name of the playbook(no spaces), the description, and select user1.  
![ansible-self-service](./demo-images/7-ansible-self-service.png)
8. Click Review.  
![self-service-review](./demo-images/8-self-service-review.png)
9. Click Create, and you should see the golden template executing, and the the steps its going through ( create src git repo, gitops repo, registering with RHDH, createing an OPenshift Gitops application which in turn creates the pipelines, and AAP artefacts).  
![self-service-execution](./demo-images/9-self-service-execution.png)
10. Once completed, you should see the result as below.  
![self-service-result](./demo-images/10-self-service-result.png)
11. Click on "Open in Catalog" to open the RHDH catalog entry.  At this point everything has been created.  You can walk through the cataelg item and all the tabs, show the code in git, and also potentially show whats been created in AAP.  For the purpose of the demo flow - we're going to move on to inner loop development in Developer Workspaces.  
![catalog-item](./demo-images/11-catalog-item.png)


## Inner Loop
For the inner loop portion of the demo, we are going to do modify the initial playbook in Developer Workspaces, and show how you can test any code changes using molecule, and with the benfit of being able to start a container, and run the playbook against the new container.
12. From the RHDH catalog item, click on the link to open Ansible Developer Workspaces, and login in as openshift admin.  
![open-devworkspaces](./demo-images/12-open-devworkspaces.png)
13. Once developerworkspaces starts - you should see the hosted vscode editor - like this.  
![devworkspaces](./demo-images/13-devworkspaces.png)
14. Click on the icon in top corner with a bar across the bottom, to bring up the terminal.  From the terminal, `cd roles/webserver` and then type `molecule test`.  You should see that the test runs through to completion.  This will create a new container, and execute the role against that new container as if it was a rhel server.  
![run-molecule-test](./demo-images/14-run-molecule-test.png)
15. Open the file roles/webserver/tasks/main.yaml to view the main tasks of the role.  
![role-tasks](./demo-images/15-role-tasks.png)
16. Now switch back to the catalog item in RHDH - and view the topology tab.  You should see two servers, the ubi8 one - which has just been created by running the molecule test, and the one with the name of the playbook - which is setup to be used by AAP as a test environment.  
![bkubernetes-topology](./demo-images/16-kubernetes-topology.png)
17. Click on the little arrow on the ubi8 icon to open the route - and you should see the following message.  
![test-server-message](./demo-images/17-test-server-message.png)
18. Now go back into Developer Workspaces, and modify the message in the roles/webserver/tasks/main.yaml file.  
![updated-test-message](./demo-images/18-updated-test-message.png)
19. Again run `molecule test` from the terminal - but this time the test should fail - as the test has a different message.  So this shows that you can easily write and test your playbooks from the Developer Worksapces, without having to check into git, and run from AAP.  
![failed-test](./demo-images/19-failed-test.png)
20. Now fix the message in the test - so open up roles/webserver/molecule/default/verify.yml and change the message in the test to be the same as the message in the role.  Save the files.  
![updated-test](./demo-images/20-updated-test.png)
21. You can either rerun the test to be 100% sure - or on the right hand side, commit and sync the changes to git.  You will need to authenticate to git as user1/Developerhub123!  
![git-commit](./demo-images/21-git-commit.png)

This is the end of the inner loop part - but it shows how a developer doesnt need to setup their laptop to write code, how they can easily test, and debug the playbook.  The final part of the demo, shows how to use AAP to test the playbook wroks from an execution environment, and finally to promote the playbook to production in the simplest way possible.  

## Path to production

In the final part of the demo - we're going to show two aspects.  One is that we have two pipelines setup.  One to run whenever a code change is made - which will lint, molecule test, and then finally update the AAP dev project with the new code changes.  The second which will run whenever we tag the code - and this will. link the tag to the production project ( i.e. having a very simple process which releases the playbook to rpdocution whenever we tag the code.). The second aspect is that AAP has been setup with a dev and prod project - a host to test against,and job templates.  This allows someone to run the new playbook from AAP, against a test server to make sure its working from the AAP environment.

22. After pushing the code to git, switch back to the catalog entry, and go to the CI tab.  You shold see the pipeline running after the trigger of a git push.  
![pipeline-running](./demo-images/22-pipeline-running.png)
23. Once the pipeline has completed, switch back the openshift console, and open the route to AAP
![navigate-to-aap](./demo-images/23-navigate-to-aap.png)
24. Log into AAP using the password from earlier, you should see the home page ( note some of the metrics willl be different).
![aap-homepage](./demo-images/24-aap-homepage.png)
25. In projects, navigate to the development project (your-playbook-name-dev), and look at the job templates tab - you can see there is a job template to deploy this playbook in dev.
![development-job-template](./demo-images/25-development-job-template.png)
26. Also navigate to the inventry, and view the inventory for your playbook.  You can see it refers to a container which you can run your playbook against ( the containers are run up slightly differentlt from normal - so that they are running systmd, and behave like a normal rhel server)
![hosts](./demo-images/26-hosts.png)
27. Navigate to the job templates page, and launch the development job template.
![launch-dev-template](./demo-images/27-launch-dev-template.png)
28. Switch back to the catalog item in RHDH.  Navigate to the topology page, and view the two servers.
![open-test-server-url-from-topology](./demo-images/28-open-test-server-url-from-topology.png)
29. Click on the arrow on the server which has the same name as your playbook.  This will. open the route to the server, and should now show the newly modified message that you have recently pushed to git.
![view-change](./demo-images/29-view-change.png)
30. For the final part - we are going to promote the current playbook to production.  To do this we need to tag the playbook.  There are many ways to do this, but this is the simplest way.  From the homepage of the catalog entry, click on `view source`.
![gitlab](./demo-images/30-gitlab.png)
31. Using the breadcrumbs at the op, navigate one folder up - to the root folder of the git project.
![gitlab-before-tagging](./demo-images/31-gitlab-before-tagging.png)
32.  Now on the right hand side, click on tags
![gitlab-no-tags](./demo-images/32-gitlab-no-tags.png)
33. Create a new tag called v1
![gitlab-v1-ta](./demo-images/33-gitlab-v1-tag.png)
34.  Switch back to RHDH, and the catalog entry, and go to the CI tab - to view the "promote to rpoduction" pipeline running.  Effectively this gets triggered whenever the code is tagged, and it will chnage the production project to be linked to that tagged version of the code.
![promote-to-prod-pipeline](./demo-images/34-promote-to-prod-pipeline.png)
35. Finally switch to AAP, and switch the production project - and you will. see that the branch/tag field is now linked to the tag you just made in git.
![production-project-with-tag](./demo-images/35-production-project-with-tag.png)

Congratulations - you've gone from nothing, to releasing your playboook into production !!
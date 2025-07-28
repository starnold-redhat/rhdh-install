# Ansible Developer Self Service

This playbook will setup a demo environment to show the ansible self service demo.  This demo has the following key steps

Log in to developerhub - and instantiate a playbook golden path ( this creates devspaces, test servers, pipelines, and AAP projects etc)
Go to dev spaces to make a change - and run molecule tests - check in code
Pipelines run to lint and test the playbook
Run the playbook from the development project in AAP against a container masquerading as a server
Promote the playbook to production, and rerun 
At this point - you've got a live playbook, which has been tested, and done it in about 30 minutes end to end.
[Optionally] make another change and see it work in the dev project, show the prod project is still running the old playbook, then promote the new change to prod.


## Setup the demo

1. Create a Openshift 4.19 environment
2. From the command line , log into the cluster.
3. Clone this repo
3. Download a manifest from redhat with an AAP subscription in it.  Store this as manifest_aap.zip in the root directory
4. Copy the example_variables.yaml to variables.yaml, and update with any specific information to your environment
5. Run the playbook - with ```ansiblansible-playbook bootstrap-backstage-playbook.yaml -e @variables.yaml```


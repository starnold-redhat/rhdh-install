# infra-gitops

## Authentication

In order to run the bootstrap playbook, you'll need credentials to authenticate to OpenShift. This can either be kubeconfig or username & password. The kubeconfig and kubeadmin passwords are in the demolab_passwords git repository. If you are running this playbook as a day 2 operation, then the kubeadmin account is not going to work and you'll need a cluster-admin user tied into IDM.

Assuming this is initial setup, start off by cloning [demolab password repository](https://gitlab.consulting.redhat.com/uki-sa/demolab/demolab_passwords). These steps assume you have cloned the repo to your home directory.

**Option 1 - kubeconfig**

```bash
cp ~/demolab_passwords/openshift/kubeconfig ~
ansible-vault decrypt ~kubeconfig
```

**Option 2 - username and password**

For the initial kubeadmin username and password:

```bash
ansible-vault view ~/demolab_passwords/openshift/kubeadmin-password
```

## execution-environment


Authenticate to quay.io using the demolab account. The credentials are in the  [demolab password repository](https://gitlab.consulting.redhat.com/uki-sa/demolab/demolab_passwords)


```bash
ansible-vault view ~/demolab_passwords/quay_repository/quay_repo.txt
podman login quay.io --username <user>
podman pull quay.io/redhat_emp1/demolab-ee:3.1.0
```

## ansible-navigator

Install example into python virtualenv:

```
python3 -m venv ~ansible-navigator
source ~./ansible-navigator/bin/activate
pip3 install ansible-navigator
```

## Run the playbook

**Option 1 - kubeconfig**

```bash
ansible-navigator run bootstrap-gitops-playbook.yaml --pp missing --eei quay.io/redhat_emp1/demolab-ee:3.1.0 --eev ~/kubeconfig:/runner/.kube/config -e @vault.yml --ask-vault-pass
```

**Option 2 - username and password**

Example for kubeadmin user. Get an API token from OCP webconsole:

```bash
export K8S_AUTH_VERIFY_SSL=false
export K8S_AUTH_HOST=https://api.infra.demolab.local:6443
export K8S_AUTH_API_KEY='sha256~sometoken'
```

Pass the variables to ansible-navigator:

```bash
ansible-navigator run bootstrap-gitops-playbook.yaml --pp missing --eei quay.io/redhat_emp1/demolab-ee:3.1.0 --penv K8S_AUTH_HOST --penv K8S_AUTH_API_KEY --penv K8S_AUTH_VERIFY_SSL -e @vault.yml --ask-vault-pass
```

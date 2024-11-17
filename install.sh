export OCP_BASE=apps.cluster-jd47r.jd47r.sandbox808.opentlc.com
oc new-project rhsso
oc apply -f sso_operator.yaml
oc wait crd --timeout=-1s keycloaks.keycloak.org   --for=condition=Established
oc apply -f sso_keycloak.yaml



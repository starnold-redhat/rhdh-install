oc delete backstage developer-hub -n backstage
oc delete keycloakuser admin -n rhsso  
oc delete keycloakuser user1 -n rhsso 
oc delete keycloakclient backstage -n rhsso 
oc delete keycloakclient openshift -n rhsso 
oc delete keycloakrealm backstage -n rhsso 
oc delete keycloakrealm openshift -n rhsso 
oc delete keycloak rhsso-instance -n rhsso 
oc delete automationcontroller controller -n aap
oc delete project rhsso
oc delete project gitlab
oc delete project backstage

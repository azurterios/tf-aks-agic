1. Create Azure AD group for AKS admin access
2. Configure subscription and tenant IDs

az aks get-credentials -n K8s-cls -g aks-agic-rg

kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml

Check cloud shell IP for whitelisting
curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'

source vars.sh
terraform init
terraform plan -lock=false
terraform apply
terraform destroy

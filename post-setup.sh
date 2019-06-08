#! /bin/bash

# Setup IAM on nodes
aws iam put-role-policy --role-name nodes.k8s.aws.lb-dev.io --policy-name kube2iam-assume --policy-document file://cluster-bootstrap/files/iam-roles/node-iam-trust.json

sleep 1m

# Setup IAM roles for ALB ingress and external-dns to assume
aws iam create-role --role-name k8s-alb-ingress --assume-role-policy-document file://cluster-bootstrap/files/iam-roles/role-iam-trust.json
aws iam create-role --role-name k8s-external-dns --assume-role-policy-document file://cluster-bootstrap/files/iam-roles/role-iam-trust.json

# Add policies for kube2iam to assume roles
aws iam put-role-policy --role-name k8s-alb-ingress --policy-name alb --policy-document file://cluster-bootstrap/files/iam-roles/alb-ingress-iam.json
aws iam put-role-policy --role-name k8s-external-dns --policy-name external-dns --policy-document file://cluster-bootstrap/files/iam-roles/external-dns-policy.json

# Setup ServiceAccount to access the Dashboard
kubectl create -f cluster-bootstrap/files/config/luke-sa.yaml

# Add Service Account for GitLab
kubectl create -f cluster-bootstrap/files/config/gitlab-sa.yaml

# Setup RBAC for Tiller
kubectl create -f cluster-bootstrap/files/config/tiller-rbac.yaml

# Setup the Weave netework encryption
./cluster-bootstrap/scripts/weave-encryption.sh

# Setup encryption on GP2 EBS volumes
kubectl delete storageclass gp2
kubectl delete storageclass default
kubectl apply -f ./cluster-bootstrap/files/config/storage.yaml

# Setup Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml --namespace=kube-system

# Setup Helm
helm init --tiller-tls --tiller-tls-cert cluster-bootstrap/files/certs/tiller.cert.pem --tiller-tls-key cluster-bootstrap/files/certs/tiller.key.pem --tiller-tls-verify --tls-ca-cert cluster-bootstrap/files/certs/ca.cert.pem --service-account=tiller
helm repo add akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/

# Wait for Tiller to initialise
echo "Waiting for Tiller to initialise..."
sleep 1m

# Setup kube2iam
helm install --name iam --namespace kube-system -f cluster-bootstrap/files/config/k2i-values.yaml stable/kube2iam --tls

# Wait for kube2iam to initialise
echo "Waiting for kube2iam to initialise..."
sleep 1m

# Setup ALB Ingress
helm install --name=alb --namespace ingress --set-string autoDiscoverAwsRegion=true --set-string autoDiscoverAwsVpcID=true --set clusterName=k8s.aws.lb-dev.io -f cluster-bootstrap/files/config/alb-values.yaml akomljen-charts/alb-ingress --tls

# Setup External-DNS
kubectl apply -f cluster-bootstrap/files/config/external-dns.yaml 

# Export GitLab Variables
./cluster-bootstrap/scripts/gitlab-vars.sh > gitlab-vars.txt
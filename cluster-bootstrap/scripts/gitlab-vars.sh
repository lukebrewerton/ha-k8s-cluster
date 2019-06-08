#! /bin/bash

# Get the CA data for GitLab

echo "Certificate Auth Data:"
echo ""
kubectl config view --raw -o json | jq -r '.clusters[0].cluster."certificate-authority-data"' | tr -d '"'
echo ""
echo "GitLab Token:"
echo ""
kubectl describe secret --namespace=kube-system gitlab | grep token | awk 'FNR == 3 {print $2}'
echo ""
echo "Service Account Token for Dashboard"
echo ""
kubectl describe secret --namespace=kube-system luke | grep token | awk 'FNR == 3 {print $2}'
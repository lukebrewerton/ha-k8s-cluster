#! /bin/bash

# Set cluster name and S3 bucket for Kops state

export NAME=k8s.aws.lb-dev.io
export KOPS_STATE_STORE=s3://lb-dev-kops-state-store

# Route53 setup
ID=$(uuidgen) && aws route53 create-hosted-zone --name aws.lb-dev.io --caller-reference $ID | jq .DelegationSet.NameServers

# S3 Bucket setup
aws s3api create-bucket --bucket lb-dev-kops-state-store --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1

aws s3api put-bucket-encryption --bucket lb-dev-kops-state-store --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
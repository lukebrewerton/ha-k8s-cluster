#! /bin/bash

# Route53 setup
ID=$(uuidgen) && aws route53 create-hosted-zone --name aws.lb-dev.io --caller-reference $ID | jq .DelegationSet.NameServers

# S3 Bucket setup
aws s3api create-bucket --bucket lb-dev-kops-state-store --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1

aws s3api put-bucket-encryption --bucket lb-dev-kops-state-store --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
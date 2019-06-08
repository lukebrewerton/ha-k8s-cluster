
#! /bin/bash

# Set cluster name and S3 bucket for Kops state

export NAME=k8s.aws.lb-dev.io
export KOPS_STATE_STORE=s3://lb-dev-kops-state-store
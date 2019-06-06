# Highly Available Kubernetes Cluster Demo
This repository contains all of the code needed to stand up a highly available Kubernetes cluster in AWS.

The cluster has the following requirements/specifications:

* 3 Master Nodes
* 3 Worker Nodes
* Uses all 3 eu-west-1 (Ireland) availability zones (eu-west-1a, eu-west-1b & eu-west-1c)
* Uses the Route53 DNS zone aws.lb-dev.io
* Uses t3.medium instances for masters and workers
* Not accessible from the internet
* Uses a bastion server
* Access is locked down to the specified IP
* Uses `kube2iam` for assuming IAM roles
* Uses `external-dns` for automatically creating Route53 records
* Uses AWS ALB for the Ingress controller
* Weave network traffic is encrypted
* EBS volumes for persistent storage are encrypted

## Requirements
To use this repository you will need the following installed:

* `kubectl` - [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* `kops` - [kops](https://github.com/kubernetes/kops#installing)
* `jq` - [jq](https://stedolan.github.io/jq/)
* `openssl` - This is included with most Linux distributions
* Helm - [Helm](https://helm.sh/docs/using_helm/)
* AWS Account with `awscli` configured

These will need to be installed on your machine before running the scripts.

## Preflight Checks
You will need to make changes to the following files in order to successfully spin up the cluster:

- `./create-cluster.sh` - You will need to change the IP for `--admin-access` and apply any tags you wish. You can also change the AWS region and availability zones in here.
- `./bootstrap.sh` - You will need to change the values for `NAME` and `KOPS_STATE_STORE` and also change the values for the Route53 setup and the S3 bucket setup. Make sure the name in the env var for the s3 bucket matches the bucket you create.

**NOTE:-** You will also need to look for any mention of `aws.lb-dev.io` and replace this with the domain you use in Route53.

### Helm Certificate Setup
In order for the Helm/Tiller components to work correctly you will need to generate the required certificates.

The commands for this are located in `cluster-bootstrap/scripts/helm-ssl`. You will need to run these to generate the keys and certificates for Helm/Tiller to correctly work.

## Usage
To start the cluster run the scripts in the following order:-
* `source ./bootstrap.sh`
* `./create-cluster.sh`
* `./post-setup.sh`

**NOTE:-** You need to run `bootstrap.sh` using `source` so that the environment variables are set correctly for `kops` to function.

## Post Setup
Once the `post-setup.sh` script has completed you will then have a fully functioning HA Kubernetes cluster. 

Included is a sample app that you can deploy to check the ingress and external DNS are functioning correctly, just run the following commands:

* `kubectl create -f sample-app.yaml`
* `kubectl create -f sample-ingress.yaml`
#! /bin/bash

# Set environment Variables
source cluster-bootstrap/files/config/env.sh

# Create the cluster

kops create cluster \
    --node-count 3 \
    --zones eu-west-1a,eu-west-1b,eu-west-1c \
    --master-zones eu-west-1a,eu-west-1b,eu-west-1c \
    --node-size t3.medium \
    --master-size t3.medium \
    --topology private \
    --networking weave \
    --cloud-labels "Team=Dev,Owner=Luke" \
    --admin-access=109.231.226.125/32 \
    --admin-access=178.128.162.175/32 \
    --bastion \
    ${NAME} \
    --yes

echo "Waiting for cluster to fully initialise..."
echo "This may take up to 10 minutes."

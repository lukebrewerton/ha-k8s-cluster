#! /bin/bash

# Create the cluster

kops create cluster \
    --node-count 3 \
    --zones eu-west-1a,eu-west-1b,eu-west-1c \
    --master-zones eu-west-1a,eu-west-1b,eu-west-1c \
    --node-size t3.medium \
    --master-size t3.medium \
    --topology private \
    --networking weave \
    --cloud-labels "Team=Dev,Owner=Luke" \ # Set your own tags here
    --admin-access=109.231.226.125/32 \ # Change this to your IP!
    --bastion \
    ${NAME} \
    --yes

echo "Waiting for cluster to fully initialise..."
echo "This may take up to 10 minutes."
echo ""
time until kops validate cluster; do sleep 10m ; done
echo "Cluster initialised!"
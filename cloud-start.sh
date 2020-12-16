#!/bin/bash

terraform init
terraform plan
terraform apply -auto-approve

echo "Cluster is ready"

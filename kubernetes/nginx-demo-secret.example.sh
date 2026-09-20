#!/bin/bash

kubectl create secret generic nginx-demo-secret \
  -n devops-lab \
  --from-literal=DEMO_TOKEN='<YOUR_SECRET>'

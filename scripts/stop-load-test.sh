#!/bin/bash

kubectl delete pod load-generator \
  -n devops-lab \
  --ignore-not-found

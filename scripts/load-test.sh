#!/bin/bash

kubectl run load-generator \
  -n devops-lab \
  --image=busybox:1.36 \
  --restart=Never \
  -- /bin/sh -c '
  i=0
  while [ $i -lt 20 ]; do
    (
      while true; do
        wget -q -O- http://nginx-demo-service >/dev/null 2>&1
      done
    ) &
    i=$((i+1))
  done
  wait
  '

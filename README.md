# Kubernetes Production Lab

A hands-on Kubernetes lab demonstrating production-oriented deployment, networking, health checks, resource management, autoscaling and rollout strategies.

The project is deployed and tested on a real K3s cluster running on a cloud server.

## Architecture

```text
                         Client
                           |
                           v
                    Traefik Ingress
                           |
                           v
                   nginx-demo-service
                           |
                    +------+------+
                    |             |
                    v             v
                  Pod 1         Pod 2
                    |
                    |
              Horizontal Pod
                Autoscaler
                    |
              Scale: 2 → 5
```

## Technologies

- Kubernetes / K3s
- Docker
- Traefik
- Metrics Server
- Nginx
- ConfigMap
- Kubernetes Secrets
- Horizontal Pod Autoscaler
- Git

## Project Structure

```text
.
├── kubernetes
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
│
├── scripts
│   ├── load-test.sh
│   └── stop-load-test.sh
│
├── .gitignore
└── README.md
```

## Features

This project demonstrates:

- Kubernetes Namespace isolation
- Multi-replica Deployment
- ClusterIP Service
- ConfigMap-based configuration
- Kubernetes Secret injection
- CPU and memory requests / limits
- Readiness probes
- Liveness probes
- Rolling Update strategy
- Rollback operations
- Traefik Ingress routing
- Horizontal Pod Autoscaling
- CPU-based scaling
- Application load testing

## Deployment

Create the namespace:

```bash
kubectl apply -f kubernetes/namespace.yaml
```

Apply the ConfigMap:

```bash
kubectl apply -f kubernetes/configmap.yaml
```

Create the Secret:

```bash
kubectl create secret generic nginx-demo-secret \
  -n devops-lab \
  --from-literal=DEMO_TOKEN='<YOUR_SECRET>'
```

Deploy the application:

```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml
```

## Verify Deployment

```bash
kubectl get all -n devops-lab
```

Check pods:

```bash
kubectl get pods -n devops-lab -o wide
```

Check application health:

```bash
kubectl exec -n devops-lab deploy/nginx-demo -- \
  sh -c 'env | grep -E "APP_NAME|APP_ENV"'
```

## Ingress

The application is exposed through Traefik Ingress.

```text
devops-lab.local
```

Test:

```bash
curl -H "Host: devops-lab.local" http://127.0.0.1
```

Traffic flow:

```text
Client
   |
   v
Traefik
   |
   v
Ingress
   |
   v
Service
   |
   v
Pods
```

## Horizontal Pod Autoscaler

The application starts with a minimum of 2 replicas and can scale up to 5 replicas.

```bash
kubectl get hpa -n devops-lab
```

Start load generation:

```bash
./scripts/load-test.sh
```

Monitor autoscaling:

```bash
kubectl get hpa -n devops-lab -w
```

Monitor pods:

```bash
kubectl get pods -n devops-lab -w
```

During testing, the deployment successfully scaled from:

```text
2 Pods → 5 Pods
```

based on CPU utilization.

Stop the load test:

```bash
./scripts/stop-load-test.sh
```

## Rolling Update

Update the container image:

```bash
kubectl set image deployment/nginx-demo \
  nginx-demo=nginx:1.27-alpine \
  -n devops-lab
```

Monitor:

```bash
kubectl rollout status deployment/nginx-demo -n devops-lab
```

The deployment uses:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

This allows new Pods to become ready before old Pods are terminated.

## Rollback

Check rollout history:

```bash
kubectl rollout history deployment/nginx-demo -n devops-lab
```

Rollback:

```bash
kubectl rollout undo deployment/nginx-demo -n devops-lab
```

Verify:

```bash
kubectl rollout status deployment/nginx-demo -n devops-lab
```

## Production Concepts Demonstrated

This lab covers several production-oriented Kubernetes concepts:

- High availability at application replica level
- Zero-downtime rolling deployments
- Application health monitoring
- Resource management
- Automatic scaling
- Service discovery
- Ingress routing
- Configuration separation
- Secret management
- Rollback strategy

## Helm Deployment

The application can also be deployed and managed using Helm.

The Helm chart is located at:

```text
helm/nginx-demo/
```

### Helm Chart Structure

```text
helm/nginx-demo/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── configmap.yaml
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── hpa.yaml
```

### Validate the Chart

```bash
helm lint helm/nginx-demo
```

Render Kubernetes manifests without deploying:

```bash
helm template nginx-demo helm/nginx-demo \
  -n devops-lab
```

### Install

The Kubernetes Secret is created separately and is not stored in Git.

```bash
kubectl create secret generic nginx-demo-secret \
  -n devops-lab \
  --from-literal=DEMO_TOKEN='<YOUR_SECRET>'
```

Install the Helm release:

```bash
helm install nginx-demo helm/nginx-demo \
  -n devops-lab
```

Verify:

```bash
helm list -n devops-lab
```

### Helm Upgrade

Configuration values can be overridden during an upgrade.

Example:

```bash
helm upgrade nginx-demo helm/nginx-demo \
  -n devops-lab \
  --set config.APP_ENV=helm-lab
```

The Deployment contains a ConfigMap checksum annotation so that configuration changes automatically trigger a rolling update of the Pods.

Verify the updated environment:

```bash
kubectl exec -n devops-lab deploy/nginx-demo -- \
  sh -c 'env | grep APP_ENV'
```

### Helm Release History

```bash
helm history nginx-demo -n devops-lab
```

Example release lifecycle tested in this lab:

```text
Revision 1 → Initial installation
Revision 2 → Helm upgrade
Revision 3 → Rollback to revision 1
```

### Helm Rollback

Rollback to a previous revision:

```bash
helm rollback nginx-demo 1 -n devops-lab
```

Verify:

```bash
kubectl rollout status deployment/nginx-demo -n devops-lab
```

This project has been tested with real Helm install, upgrade and rollback operations on a running K3s cluster.

## Future Improvements

Planned improvements:

- Helm chart
- Prometheus and Grafana
- Argo CD / GitOps
- Istio Service Mesh
- Persistent Volumes
- Network Policies
- CI/CD integration
- TLS Ingress
- Multi-node Kubernetes testing

## Author

**Harun Sert**

DevOps Engineer

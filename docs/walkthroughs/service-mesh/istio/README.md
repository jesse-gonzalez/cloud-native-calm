# Istio Tasks

## Pre-requisites

- Istio Helm Chart BP
- Day 2 BookInfo App Deployed

kubectl get deployments,hpa,svc,ingress -n istio-system

kubectl get deployments,svc,virtualservices,gateways -n bookinfo

kubectl get virtualservices -o yaml -n bookinfo

kubectl get gateways -o yaml -n bookinfo

> Validate Sidecar being configured on bookinfo productpage app

krew install images
kubectl images $(kubectl get po -o name -l app=productpage | cut -d / -f2) -n bookinfo

## Traffic Management Scenarios

### Request Routing

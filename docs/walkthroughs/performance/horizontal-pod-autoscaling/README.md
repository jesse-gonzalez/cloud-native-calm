# Demo

This demo is based off of https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

This is basically a custom docker image that has simple index.php page which performs some CPU intensive computations

It will create a namespace called "stress" on target cluster.

## Step 1. Deploy

cd demos/karbon-walkthrough/horizontal-pod-autoscaling
./deploy_stress_app.sh

## Step 2. Monitor

watch -n 1 "kubectl get deploy,pods,hpa"

## Step 3. Cleanup

kubectl delete namespace stress

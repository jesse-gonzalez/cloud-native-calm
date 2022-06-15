kubectl apply -f infra/.
kubectl apply -f journal/redis/redis-master-service.yaml
kubectl wait --for=condition=Ready po -l role=master
kubectl apply -f journal/redis/.
kubectl wait --for=condition=Ready po -l role=slave
kubectl apply -f journal/frontend/.
# Use the Horizontal Pod Autoscaler for apps with variable usage patterns
kubectl autoscale deployment frontend --min=2 --max=10 --cpu-percent=50

# Server component of cocalc-kubernetes

For now we will just record some instructions for those who know
Kubernetes to get this running.  Once everything works, we'll
automate this with a helm chart.

```
kubectl apply -f deployment.yaml
kubectl expose deployment cocalc-server
```

Then figure out the pod name and forward it to localhost, so you
can then connect to cocalc at https://localhost:4043
```
kubectl port-forward cocalc-server-5588cbb9c5-m8qqk 4043:443
```

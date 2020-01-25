# Server component of cocalc-kubernetes

To get this working you have to following these steps:

## Installing the cocalc-server into a namespace in your Kubernetes cluster

1. Create the service account called cocalc-kubernetes-server

```
kubectl create serviceaccount cocalc-kubernetes-server
```

2. Make the service account have some powers

```
kubectl create rolebinding cocalc-kubernetes-server-binding --role=admin --serviceaccount=cocalc-kubernetes-server
```

TODO: the account doesn't need admin for the namespace, but I haven't done something more precise yet...

3. (Optional) Edit deployment.yaml so that the projects volume isn't ephemeral.

If you don't do this step, your server will be completely ephemeral, and everything
will be deleted when you stop it.

4.  Create the cocalc server deployment

```
kubectl apply -f deployment.yaml
```

5. Expose the deployment

```
kubectl expose deployment cocalc-kubernetes-server
```

6. Create the NFS service (that projects will mount)

```
kubectl apply -f nfs-service.yaml
```

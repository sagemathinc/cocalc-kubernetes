# Server component of cocalc-kubernetes

To get this working you have to following these steps:

## Installing the cocalc-server into a namespace in your Kubernetes cluster

1. Create the service account called cocalc-kubernetes-server

```
kubectl create serviceaccount cocalc-kubernetes-server
```

2. Make the service account have some powers

Replace `default` below by whatever namespace you are install CoCalc into:

```
kubectl create rolebinding cocalc-kubernetes-server-binding --role=admin --serviceaccount=default:cocalc-kubernetes-server
```

TODO: the account doesn't need admin for the namespace, but I haven't done something more precise yet...

3. (Optional) Edit deployment.yaml so that the projects volume isn't ephemeral.

If you don't do this step, your server will be completely ephemeral, and everything
will be deleted when you stop it.  It should still work fine, and is probably a good 
idea for a first quick test.

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

7. Networking security for project pods

**TODO!**

It's critical for security that the project pods that cocalc-kubernetes-server creates
are not allowed to connect to anything inside of your Kubernetes cluster.
They will have the label
```
run: project
```
so you have to use Kubernetes networking control to make it so they can't
connect to anything else...  If you don't do this, then things are not secure,
since one project could connect to an HTTP server of another project, and
do malicious things.

The only networking that project pods need are the cocalc-kubernetes-server 
must be able to connect to them via TCP on any port.  That's it.  It's also
often convenient for users if they can connect from a project to the outside
world.
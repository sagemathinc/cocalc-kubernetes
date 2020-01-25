# Installation instructions.

## Architecture

The architecture of cocalc-kubernetes is that there there is one 
server deployment called `cocalc-kubernetes-server` that creates
one pod that handles everything related to services.  There is
also one pod for each running project, called `project-[project_id]`.
When running, it might look like this:
```
~# kubectl get deployments
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
cocalc-kubernetes-server   1/1     1            1           29m
~# kubectl get pods
NAME                                           READY   STATUS    RESTARTS   AGE
cocalc-kubernetes-server-854cbd774c-qchxm      1/1     Running   0          26m
project-61897eab-8079-442c-aa66-6cb77d43c727   1/1     Running   0          15m
project-f508f833-2e4d-46e3-bd03-4b67489a025c   1/1     Running   0          19m
```

To get CoCalc up and running, you have to install cocalc-kubernetes-server.
It will then create projects for you. Also, all images are on DockerHub, so you
don't have to build anything.

## How to install the cocalc-kubernetes-server into a namespace in your Kubernetes cluster

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

8. Forward the https port from CoCalc to your local computer, so that you can try it out in your web browser:

```
kubectl port-forward service/cocalc-kubernetes-server 4043:443
```

The above will make it so if you open https://localhost:4043 in your web browser,
then you'll see your new cocalc-kubernetes server!  If port 4043 is already in 
use on your machine, just choose a different port.

If you're controlling kubectl via a remote machine, instead do

```
kubectl port-forward --address 0.0.0.0 service/cocalc-kubernetes-server 4043:443
```

then connect to https://ip.of.remote.machine:4043

Of course this is less secure, and if your remote machine is behind a firewall, you
will have to open up access to port 4043.

9. Make your service publically visible

How to do this may depend on how you're using Kubernetes.  You might
start [here in the Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#exposing-the-service).
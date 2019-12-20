# cocalc-kubernetes

This doesn't exist yet, but will be a free open source slightly modified version of [cocalc-docker](https://github.com/sagemathinc/cocalc-docker) but for running cocalc on a Kubernetes cluster.

## Discussion

cocalc-kubernetes we be an open source (but AGPL) version of CoCalc that can be run on an existing generic Kubernetes cluster.

It is as similar as possible to [cocalc-docker](https://github.com/sagemathinc/cocalc-docker), with only the following changes:
  1. It runs in a Kubernetes cluster rather than a local Docker install, and
  2. Projects run as separate pods on the cluster rather than all in the same Docker container.

The benefit of this architecture include:
  - Projects can have individual resource limitations imposed by Kubernetes
  - The security issues with cocalc-docker (involving projects connecting to other project services on localhost) can be addressed by blocking outgoing network connections from projects
  - Projects run across a cluster, so the number of projects that one can run at once is a function of the number (and size) of nodes in the cluster, rather than cocalc-docker host.
  - This can be done with just a slight modifictaion and addition to the entirely open source (AGPL) codebase that cocalc-docker uses.
  
The drawbacks of this architecture over a more complicated architecture like KuCalc (what https://cocalc.com uses) include:
  - It is unclear to what extent it can handle a large number of *simultaneous users*, since the entire server component (the datbase, hub, NFS file server, etc.) are served from a single pod.
  - Project storage is just a single NFS server, so iops may be lower for client projects, which may or may not be an issue depending on the network and use of projects.
  - Snapshots and automated backups have to be handled outside cocalc somehow.  This is the responsibility of the admin.
  - The project image is much more minimal than the one provided by cocalc.com -- it has to be small enough to reasonably run in a normal way without pull taking too long.
  
  
PLAN:
 - I'm going to quickly get a private proof of concept working using our existing "kucalc" scripting infrastructure, since that's easy to do, develop, iterate on and test.
 - Then we can worry about packaging this to run outside cocalc using helm charts, instructions or whatever.  That will go in this public repo [cocalc-kubernetes](https://github.com/sagemathinc/cocalc-kubernetes).

# **This is not currently being updated.**
# See https://cocalc.com/pricing/onprem


---

# cocalc-kubernetes

This was a free open source AGPL licensed slightly modified version of [cocalc-docker](https://github.com/sagemathinc/cocalc-docker), but for running CoCalc on a Kubernetes cluster.  There is one pod for the server and one pod for each project.

## STATUS

- This is not currently being updated.

- We sell a **much** better scalable Kubernetes based version of CoCalc, but it's not open source. It contains some proprietary extensions we developed and battle tested for https://cocalc.com. It's based on flexible [HELM charts](https://helm.sh/) (a way to configure services in a kubernetes cluster) and it's currently working with GKE (Google Compute Engine's managed kubernetes cluster) and bare-metal Kubernetes clusters. It shouldn't be too hard to make it work on other Kubernetes clusters. The pricing is higher than [cocalc-docker](https://github.com/sagemathinc/cocalc-docker), depending on the installation and is proportional to the number of users.  Contact us at help@cocalc.com for more information.

## Installation

See [server/README.md](./server/README.md) to get going!

## LICENSE AND SUPPORT

  - Much of this code is licensed [under the AGPL](https://en.wikipedia.org/wiki/Affero_General_Public_License). If you would instead like a business-friendly MIT license, please contact [help@cocalc.com](mailto:help@cocalc.com), and we will sell you a 1-year license for $1499.  This also includes some support, though with no guarantees (that costs more).
  - Join the [CoCalc Docker mailing list](https://groups.google.com/a/sagemath.com/group/cocalc-docker) for news, updates and more.
  - Use the [CoCalc mailing list](https://groups.google.com/forum/?fromgroups#!forum/cocalc) for general community support.

## SECURITY STATUS

  - If you setup everything as explained in [server/README.md](./server/README.md), including appropriate network restrictions on the project pods, then there are no known security vulnerabilities.  In particular, this is much safer to run than [cocalc-docker](https://github.com/sagemathinc/cocalc-docker), if you are going to expose this to untrusted (or uncareful) users.

## Discussion

cocalc-kubernetes is an open version of CoCalc that can be run on an existing generic Kubernetes cluster.

It is as similar as possible to [cocalc-docker](https://github.com/sagemathinc/cocalc-docker), with the following changes:
  1. It runs in a Kubernetes cluster rather than a plain Docker install, and
  2. Projects run as separate pods on the cluster rather than all in the same Docker container.

The benefits of this architecture include:
  - Projects can have individual resource limitations imposed by Kubernetes.
  - The security issues with cocalc-docker (involving projects connecting to other project services on localhost) can be addressed by blocking outgoing network connections from projects.
  - Projects run across a cluster, so the number of projects that one can run at once is a function of the number (and size) of nodes in the cluster, rather than cocalc-docker host.
  - This can be done with just a slight modification and addition to the entirely open source (AGPL) codebase that cocalc-docker uses.
  
The drawbacks of this architecture over a more complicated architecture like the closed-source KuCalc (what https://cocalc.com uses) include:
  - It is unclear to what extent it can handle a large number of *simultaneous users*, since the entire server component (the database, hub, NFS file server, etc.) are all served from a single pod.
  - Project storage is just a single NFS server, so disk iops may be lower for client projects, which may or may not be an issue depending on the network and use of projects.
  - Filesystem level snapshots and other backups have to be handled outside CoCalc.  This is the responsibility of the admin and is not part of cocalc-kubernetes at present.  However, the [TimeTravel](https://doc.cocalc.com/time-travel.html) functionality, which records every version of a file or notebook while you work on it, and lets you browse all past versions, does **fully work** in cocalc-kubernetes.
  - The project image is much more minimal than the one provided by https://cocalc.com -- it has to be small enough to reasonably run in a normal way without pull taking too long.  The image in KuCalc is hundreds of gigabytes but mounts quickly using some sophisticated tricks.

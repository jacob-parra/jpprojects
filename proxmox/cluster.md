---
title: Cluster
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">

## Clustering

The Proxmox Cluster feature allows multiple distinct Proxmox servers to act as Nodes in a combined Cluster. This allows for central management as well as redundancy, which improves uptime. 

#### 1. Create the Cluster

On the first server/node, create your cluster with this command in the shell : `pvecm create <cluster name>`.

Check that it was created with `pvecm status`. You should see the cluster you just created listed there.

#### 2. Join the Cluster

On the other server/node, join the cluster by running this command in the shell: `pvecm add <IP_OF_NODE1>`.

#### 3. 
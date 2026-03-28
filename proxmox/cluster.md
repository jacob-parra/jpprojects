---
title: Cluster
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">

## Clustering

The Proxmox Cluster feature allows multiple distinct Proxmox servers to act as Nodes in a combined Cluster. This allows for central management, easier node control and the ability to manulaly move workloads across the nodes. 

<div class="info">
When creating a cluster, one node acts as the base where the cluster is created. For best results, every other node should be a fresh install of Proxmox. See the <a href="https://jacob-parra.github.io/jpprojects/proxmox/migration">Migration</a> page to see how to move VMs and Containers from one server to another to facilitate a clean reinstall.
</div>

These are the steps for creating a Proxmox server cluster.

#### 1. Create the Cluster

On the first server/node, create your cluster with this command in the shell : `pvecm create <cluster name>`.

Check that it was created with `pvecm status`. You should see the cluster you just created listed there.

#### 2. Join the Cluster

On the other server/node, join the cluster by running this command in the shell: `pvecm add <IP_OF_NODE1>`. It will take a moment, but when it finishes you'll see each not listed in the left menu when you refresh.

#### 3. Set DNS

Every node in the cluster needs to be able to ping eachother, both via IP address and hostname. This can be set manually to prevent headaches later.

For each node, edit `nano /etc/hosts` and add a line for each node in the cluster:

`<node ip address> <node host name>`

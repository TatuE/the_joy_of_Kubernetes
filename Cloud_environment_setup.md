# Setting up Hetzner Cloud

## *Prerequisites*

1. **Hetzner Cloud Account:** You need an active account 
2. **Local Tools:** `kubectl` (the Kubernetes command-line tool) installed on your local machine. Optionally, install `helm`.


## 1. Creating a new project

We started off by creating a new could project. I Hetzner this is quite straightforward.

![New project 1](Pictures/Hetzner_cloud/Hetzner_cloud_new_project.png)
![New project 1](Pictures/Hetzner_cloud/Hetzner_cloud_new_project_name.png)

### 1.1 Enable connectivity

1. **SSH Key** 
    * Add the needed public SSH keys to the Hetzner project (Security \-\> SSH Keys). 
2. **API Token** 
    * Generate an API token within the Hetzner Cloud project (Security \-\> API Tokens). Grant it **Read & Write** permissions. Store this token securely.  

## 2. Setting up infrastructure for the new project

**Use Hetzner Cloud Console in the project**  

1. **Create 3 Cloud Servers (1 control-plane, 2 workers)**
    * **Location:** Helsinki (hel1)  
    * **ISO Image:** Ubuntu 24.04  
    * **Type:** CX22 (Intel, 2 vCPU:s, 4 GB RAM, 40 GB SSD, 20 TB Traffic)  
    * **SSH Key:** Public key from project members computer  
    * **Naming:** k8s-control-plane-1, k8s-worker-1, k8s-worker-2
2. **Create Private Network:**
  * **Name:** k8s-private-network
  * **IP range:** 10.0.0.0/16
  * Attach all 3 servers.
    * **Note**, the servers have now an IP on a public and a private network, on two different interfaces.
3. **Create Firewall:** 
  * **Name:** k8s-firewall-1
  * **Inbound Rules:** 
    * Allow:
      * SSH (TCP/22 from your All IPV4 (Restrict to my IP in the future)) 
      * K8s API (TCP/6443 from your All IPV4 (Restrict to my IP in the future)) 
      * NodePorts (TCP/30000-32767 from All IPV4)
      * K3s internal ports (UDP/8472, TCP/10250 from private network IPs)
      * ICMP (from private network IPs).  
    * **Outbound Rules:** 
      * Allow all.  
    * Apply to all 3 servers.

![New project 1](Pictures/Hetzner_cloud/Hetzner_cloud_project_instances.png)

## 3 Start Kubernetes deployment

Now that we have are infrastructure setup, we can start installing Kubernetes and deploying the cluster.

### 3.1.1 Install Kubernetes control plane

Install K3s in the k8s-control-plane-1 machine.
In this case we use the [install_K3s_server](scripts/install_K3s_server.sh) script.
The easiest way was just to copy ``scp`` the shell script from the local machine to the virtual machine and make it and executable ``chmod -x``. 
Once this is done, we just executed the script and check the installation was performed without error.

![k8s-control-plane-1](Pictures/K3s_control-plane-1/Screenshot%202025-05-01%20at%2018.35.44.png)

### 3.1.2 Get the K3s token

Once the installation is done, we need the k3s token from the control-plane for the worker node installation.  
``cat /var/lib/rancher/k3s/server/node-token``
We copied this to be used in the worker node installation.

## 3.2 Install Kubernetes Worker nodes

Install K3s in the worker-node machines (k8s-worker-1 & k8s-worker-2).
We are using the same script base as with the K3s server installation but with a few modifications, primarily we define the control-plane IP-address and K3S token. All of this is explained in the [agent installation script](Scripts/install_K3s_worker.sh).

![k8s-workers](Pictures/K3s_workers/Screenshot%202025-05-01%20at%2019.04.36.png)

## 3.3 Get the Kubernetes configuration for local management

Once the worker nodes are installed, we need to get the control-plane configuration, so we can manage to kubernetes network from a local computer (in our case using ``kubectl``).

we copied the ks3.yaml configuration file (located at ``/etc/rancher/k3s/k3s.yaml``) from the k8s-control-plane-1 machine to our local computer. In the file, we edit the ``server``address (which is local host (127.0.0.1) by default) with the IP of the  k8s-control-plane-1 machine. 

once done, we refer this .yaml file as the Kubernetes configuration for ``kubectl``. 
After this, we can check if we can connect to the Kubernetes cluster.

![kubectl-check_cluster](Pictures/kubectl/Screenshot%202025-05-01%20at%2020.36.22.png)



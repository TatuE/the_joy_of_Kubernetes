# Setting up Hetzner Cloud

## *Prerequisites*

1. **Hetzner Cloud Account:** You need an active account 


and a project set up.  
2. **API Token:** Generate an API token within your Hetzner Cloud project (Security \-\> API Tokens). Grant it **Read & Write** permissions. Store this token securely.  
3. **SSH Key:** Add your public SSH key to your Hetzner project (Security \-\> SSH Keys).  
4. **Local Tools:** Install `kubectl` (the Kubernetes command-line tool) on your local machine. Optionally, install `helm`.


## 1. Creating a new project

We started off by creating a new could project. I Hetzner this is quite straightforward.

![New project 1](Pictures/Hetzner_cloud/Hetzner_cloud_new_project.png)
![New project 1](Pictures/Hetzner_cloud/Hetzner_cloud_new_project_name.png)

## 2. Setting up infrastructure for the new project

**Quick notes**

**Use Hetzner Cloud Console in the project**  

1. **Create 3 Cloud Servers (1 control-plane, 2 workers)**
     * **Location:** Helsinki (hel1)  
     * **ISO Image:** Ubuntu 24.04  
     * **Type:** CX22 (Intel, 2 vCPU:s, 4 GB RAM, 40 GB SSD, 20 TB Traffic)  
     * **SSH Key:** Public key from project members computer  
     * **Naming:** k8s-control-plane-1, k8s-worker-1,k8s-worker-2  
2. **Create Private Network:**
   * Name: k8s-private-network
   * IP range : 10.0.0.0/16   
   * Attach all 3 servers.  
3. **Create Firewall:** 
   * Name: k8s-firewall-1
   * **Inbound Rules:** 
     * Allow:
       * SSH (TCP/22 from your All IPV4 (Restrict to my IP in the future)) 
       * K8s API (TCP/6443 from your All IPV4 (Restrict to my IP in the future)) 
       * NodePorts (TCP/30000-32767 from All IPV4)
       * k3s internal ports (UDP/8472, TCP/10250 from private network IPs)
       * ICMP (from private network IPs).  
   * **Outbound Rules:** 
     * Allow all.  
   * Apply to all 3 servers.


![New project 1](Pictures/Hetzner_cloud/Hetzner_cloud_project_instances.png)

## 3. Preparing Kubernetes deployment

Install k3s in the k8s-control-plane-1 machine. 

```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --flannel-iface=enp7s0 --node-ip="10.0.0.2" --node-external-ip=$(curl -4 ifconfig.me)" sh -s -
```

### Notes on shell script


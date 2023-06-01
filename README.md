
# Ceph K8s Cluster on AWS EC2 using terraform
[![Up to Date](https://github.com/ikatyang/emoji-cheat-sheet/workflows/Up%20to%20Date/badge.svg)](https://github.com/ikatyang/emoji-cheat-sheet/actions?query=workflow%3A%22Up+to+Date%22)

# What is Rook?

Rook is an open source **cloud-native storage orchestrator** for Kubernetes, providing the platform, framework, and support for Ceph storage to natively integrate with Kubernetes.

[Ceph](https://ceph.com/) is a distributed storage system that provides file, block and object storage and is deployed in large scale production clusters.

Rook automates deployment and management of Ceph to provide self-managing, self-scaling, and self-healing storage services.
The Rook operator does this by building on Kubernetes resources to deploy, configure, provision, scale, upgrade, and monitor Ceph.

## Documentation

This code is to deploy the EC2 Ubuntu 20.04 on AWS Cloud through the terraform. After this we have to use the ansible playbooks to install the vanilla K8s cluster. 

We use the dynamic inventory for ansible-playbook execution using the plugin aws_ec2.

Please pull the GitHub code "https://github.com/sanjeevrana-k8s-ceph.git"

Update the credentials in ~/.aws/credentials, else export the AWS access_key, secret_key and region on the shell.


##  Pre Requisite

Need the aws account, IAM user with privileges to deploy the EC2.

Need Access and Secret Keys

On the Workstation (ubuntu 20.04).:point_down:

- Install the terraform
   https://learn.hashicorp.com/tutorials/terraform/install-cli
  ```python
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
  apt update && apt install terraform
  ```

- Install the python3, pip, python3-pip, and boto3
  ```python
  apt-get install python3 -y
  apt-get install python3-pip -y
  pip3 install boto3
  ansible-galaxy collection install community.kubernetes
  ```

- Install the Ansible
  ```python
  apt-get update
  apt-get install ansible -y
  ```
- Put the changes in /etc/ansible/ansible.cfg
```python
inventory       = /terraform/ansible/inventory/aws_ec2.yaml
host_key_checking = False
pipelining = True
private_key_file = /terraform/mykey-pair
remote_tmp = $HOME/.ansible/tmp/
user = ubuntu
sudo_user = root
enable_plugins = aws_ec2
```

## Else, pull the docker image and then run the ./infra-k8.sh
```python
docker run -it -d --name my_ceph_sandbox sanjeevranahp/myceph:1.0
docker exec -it my_ceph_sandbox bash
cd /terraform
./infra-k8.sh 
```
Before run the ./infra-k8.sh options, export the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN (optional if required)

options

- --create-cluster  create the infra and install the k8s.
- --create-ceph     create the infra, install k8s and Ceph Storage
- --delete-cluster  delete the k8s cluster with infra.


## Installation

Once the GitHub repository is cloned, and all the pre-requisites are done on the workstation then execute the below commands.

1. To get the correct options
```python
./infra-k8.sh -h

here's the options:
========================

--create-cluster  create the infra and install the k8s.
--create-ceph     create the infra, install k8s and Ceph Storage
--delete-cluster  delete the k8s cluster with infra.
```


2. The below script will create the four EC2 instances (1 kube-master & 3 kube-worker), along with extra EBS volumes using the terraform, and install the k8s and ceph using the ansible-playbook :ok_hand:
```python
cd /terraform/
./infra-k8.sh --create-cluster
```


3. This will delete the infrastructure :cowboy_hat_face:

```python
cd /terraform/
./infra-k8.sh --delete-cluster
```

To access the ec2, there is a keypair generated in the /terraform directory, so you can execute the below command. Public IP address for the instances will display at the end of the script.

- ssh -i mykey-pair ubuntu@ec_ipaddress

## Troubleshooting Steps
Once the rook-ceph-tools pod is running, you can connect to it with:
```python
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
```
All available tools in the toolbox are ready for your troubleshooting needs.

Example:
- ceph status
- ceph osd status
- ceph df
- rados df

# Kubernetes Tools
Kubernetes status is the first line of investigating when something goes wrong with the cluster. Here are a few artifacts that are helpful to gather:

- Rook pod status:
  
  kubectl get pod -n <cluster-namespace> -o wide
  e.g., kubectl get pod -n rook-ceph -o wide
   
- Logs for Rook pods
  Logs for the operator: kubectl logs -n <cluster-namespace> -l app=<storage-backend-operator>
  e.g., kubectl logs -n rook-ceph -l app=rook-ceph-operator
- Logs for a specific pod: kubectl logs -n <cluster-namespace> <pod-name>, or a pod using a label such as mon1: kubectl logs -n <cluster-   namespace> -l <label-matcher>
  e.g., kubectl logs -n rook-ceph -l mon=a
- Logs on a specific node to find why a PVC is failing to mount:
  Connect to the node, then get kubelet logs (if your distro is using systemd): journalctl -u kubelet
- Pods with multiple containers
  For all containers, in order: kubectl -n <cluster-namespace> logs <pod-name> --all-containers
  For a single container: kubectl -n <cluster-namespace> logs <pod-name> -c <container-name>
- Logs for pods which are no longer running: kubectl -n <cluster-namespace> logs --previous <pod-name>
  Some pods have specialized init containers, so you may need to look at logs for different containers within the pod.
- kubectl -n <namespace> logs <pod-name> -c <container-name>
  Other Rook artifacts: kubectl -n <cluster-namespace> get all

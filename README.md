
# K8s Cluster on AWS EC2 using terraform
[![Up to Date](https://github.com/ikatyang/emoji-cheat-sheet/workflows/Up%20to%20Date/badge.svg)](https://github.com/ikatyang/emoji-cheat-sheet/actions?query=workflow%3A%22Up+to+Date%22)



## Documentation

This code is to deploy the EC2 Ubuntu 20.04 on AWS Cloud through the terraform. After this we have to use the ansible playbooks to install the vanilla K8s cluster. 

We use the dynamic inventory for ansible-playbook execution using the plugin aws_ec2.

Please pull the GitHub code "https://github.com/sanjeevrana-hp/aws-vanilla-k8s.git"

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
- --delete-cluster  delete the k8s cluster with infra.


## Installation

Once the GitHub repository is cloned, and all the pre-requisites are done on the workstation then execute the below commands.

1. To get the correct options
```python
./infra-k8.sh -h

here's the options:
========================

--create-cluster  create the infra and install the k8s.
--delete-cluster  delete the k8s cluster with infra.
```


2. The below script will create the two EC2 (kube-master & kube-worker) using the terraform, and install the k8s using the ansible-playbook :ok_hand:
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

## Ceph Installation
cd /var/tmp
git clone --single-branch --branch master https://github.com/rook/rook.git
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
kubectl -n rook-ceph get pod ( to check the ceph pod status, and wait until it's running)
kubectl create -f dashboard-external-https.yaml
# To get the passord for admin user.
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

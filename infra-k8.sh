#!/bin/bash
case $1 in
        "--create-cluster")
                echo "Creating the EC2 Instances, and installing the K8s"
		cd /terraform
                terraform init
                terraform apply --auto-approve
		sleep 45
		cd /terraform/ansible
                ansible-playbook master-kubernet.yaml
                ansible-playbook worker-kubernet.yaml
		cd /terraform
		terraform output
                ;;

        "--create-ceph")
                echo "Creating the EC2 Instances, and installing the K8s"
                cd /terraform
                terraform init
                terraform apply --auto-approve
                sleep 45
		echo "Installing the K8s"
                cd /terraform/ansible
                ansible-playbook master-kubernet.yaml
                ansible-playbook worker-kubernet.yaml
		sleep 30
		echo "Installing the Ceph Storage using Rook"
		cd /terraform/ansible/rook-ceph
		ansible-playbook ceph-storage.yaml
		cd /terraform
		terraform output
		echo "Here's the useful URL, and creds for Ceph Storage"
		public_ip=`terraform state show aws_instance.k8s_manager |grep public_dns |cut -d '"' -f2`
		creds=`cat /terraform/ansible/rook-ceph/ceph-creds.txt`
                echo "Ceph Storage URL ->  http://$public_ip:32528"
		echo "Ceph Creds for admin user -> $creds"
                ;;

        "--delete-cluster")
                echo "Deleting K8s, and EC2"
		cd /terraform
                terraform destroy --auto-approve
                ;;
 
	 *)
           echo "Invalid option. Please use the -h to know the right options"
	   ;;
esac


Help()
{
   echo "here's the options:"
   echo "------------------------"
   echo "--create-cluster  create the infra and install the k8s."
   echo "--delete-cluster  delete the k8s cluster with infra."
   echo "--create-ceph  create the infra,k8s cluster along with Ceph."
   echo
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

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
		echo "Installing the StorageClasses"
		cd /terraform/ansible/rook-ceph
		ansible-playbook ceph-storage.yaml
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
   echo "--create-msrv3  create the infra,k8s cluster along with MSRv3."
   echo
}

while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

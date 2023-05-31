variable "host_names" {
  type    = list(any)
  default = ["kube-worker-1", "kube-worker-2", "kube-worker-3"]
}

variable "instance_type" {
  default = "t2.large"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "aws_shared_credentials_file" {
  type    = string
  default = "~/.aws/credentials"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "name" {
  default = "k8s-ceph"
}

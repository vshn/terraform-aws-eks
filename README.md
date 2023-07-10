# VSHN Terraform Module AWS EKS

This module does the following:

* Create a virtual network for the EKS cluster
* Create a subnet for the EKS cluster
* Create an EKS cluster


# Documentation 
## EKS managed node groups

To configure EKS managed node groups, you have the `worker_availability_zones` key which is not represented in the Terraform module https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest. This was implemented, to have an easier way to configure in which zones a node group should be deployed. By default, only subnet_ids we're supported, which are not useful because they're not known and bootstrapping time or have to be looked up later to know which zone they are.

This key can be used if you would like to deploy a EKS managed node group to a specific availability zone (e.g. `node_group_a` or `node_group_b`). If you don't add the key to the object (`node_group_c`) all the subnet_ids of the cluster are added to the node group, that means the node group will be deployed to all the AZ from the cluster itself.

```
eks_managed_node_groups = {
  node_group_a = {
    ami_id                    = "ami-0001b60211a86578d"
    instance_types            = ["m6a.large"]
    min_size                  = 1
    max_size                  = 1
    desired_size              = 1
    worker_availability_zones = ["eu-west-1a"]
  }
  node_group_b = {
    ami_id                    = "ami-0001b60211a86578d"
    instance_types            = ["m6a.large"]
    min_size                  = 1
    max_size                  = 1
    desired_size              = 1
    worker_availability_zones = ["eu-west-1a", "eu-west-1b"]
  }
  node_group_c = {
    ami_id                    = "ami-0001b60211a86578d"
    instance_types            = ["m6a.large"]
    min_size                  = 1
    max_size                  = 1
    desired_size              = 1
  }
}
```

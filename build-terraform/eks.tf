data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks"
  cluster_version = "1.21"
  subnet_ids        =["${module.vpc.public_subnets[0]}","${module.vpc.public_subnets[1]}"]
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {

    worker = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      capacity_type  = "SPOT"
      key_name = "server-keypair"
      bootstrap_extra_args = "--enable-docker-bridge true"
      instance_types = ["t2.medium"]
      k8s_labels = {
        Environment = "worker"
      }
    }

  }

}

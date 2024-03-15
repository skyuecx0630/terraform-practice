module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.resource_name_tag_perfix}-cluster"
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  control_plane_subnet_ids       = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    app = {
      ami_type                       = "AL2023_x86_64_STANDARD"
      platform                       = "al2023"
      use_latest_ami_release_version = true

      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }
    }
  }

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}

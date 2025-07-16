module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "zantac-vpc"
  cidr   = var.vpc_cidr

  azs             = ["us-west-1a", "us-west-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}


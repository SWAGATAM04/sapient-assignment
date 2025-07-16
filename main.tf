provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source     = "./modules/security"
  vpc_id     = module.vpc.vpc_id
}

module "ec2_asg" {
  source              = "./modules/ec2_asg"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  sg_id               = module.security.web_sg_id
  key_name            = var.key_name
  user_data_file_path = "${path.module}/bootstrap.sh"
}

module "iam_user" {
  source    = "./modules/iam"
  user_name = "restart-web-user"
}


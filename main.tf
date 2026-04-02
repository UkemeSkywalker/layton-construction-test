/*
  Heidi Health - Terraform Practical Exercise

  This project provides a small baseline Terraform structure.
*/

terraform {
  required_version = ">= 1.6.0"
}

module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source = "./modules/rds"

  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.vpc.rds_security_group_id]
}

module "ec2" {
  source = "./modules/ec2"

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.vpc.ec2_security_group_id]
}

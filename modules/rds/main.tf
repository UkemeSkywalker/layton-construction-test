module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "careledger"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "careledger"
  username = "user"
  port     = "5432"


  vpc_security_group_ids = var.vpc_security_group_ids



  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  
}
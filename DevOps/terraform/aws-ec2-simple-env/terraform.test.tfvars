# AWS Configuration
aws_region   = "ap-southeast-1"
project_name = "simple-app"

# VPC Configuration
vpc_cidr             = "10.0.0.0/24"
availability_zones   = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnet_cidrs  = ["10.0.0.0/26", "10.0.0.64/26"]
private_subnet_cidrs = ["10.0.0.128/26", "10.0.0.192/26"]

# EC2 Configuration
instance_count    = 1
ami_id            = "ami-0c56f26c1d3277bcb"
instance_type     = "t3.micro"
volume_size       = 20
app_port          = 3000
health_check_path = "/"

# Database Configuration
db_engine                = "mysql"
db_engine_version        = "8.0"
db_instance_class        = "db.t3.micro"
db_allocated_storage     = 20
db_max_allocated_storage = 100
db_name                  = "appdb"
db_username              = "admin"
db_port                  = 3306
db_skip_final_snapshot   = true

# SSH Key
key_name = "app-db-key"


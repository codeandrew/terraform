provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr_block

  # Set the public subnet flag to true
  map_public_ip_on_launch = true

  # Create the subnet in the first availability zone in the region
  availability_zone = data.aws_availability_zones.available.names[0]
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr_block

  # Create the subnet in the second availability zone in the region
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_cluster" {
  name = "eks-cluster-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:Describe*",
          "eks:Describe*",
          "eks:List*",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = aws_iam_policy.eks_cluster.arn
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "my_cluster" {
  name = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [aws_subnet.private_subnet.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

resource "aws_eks_node_group" "workers" {
  cluster_name = aws_eks_cluster.my_cluster.name
  node_group_name = "workers"
  node_role_arn = aws_iam_role.eks_worker.arn
  subnet_ids = [aws_subnet.private_subnet.id]
  instance_types = ["t2.medium"]
  scaling_config {
    desired_size = 3
    max_size = 3
    min_size = 3
  }
}


# Create a managed MySQL instance
resource "aws_rds_cluster" "mysql" {
  engine                            = "aurora-mysql"
  engine_version                    = "5.7.mysql_aurora.2.07.1"
  database_name                     = "mydb"
  master_username                   = var.db_username
  master_password                   = var.db_password
  backup_retention_period           = 7
  preferred_backup_window           = "07:00-09:00"
  port                              = "3306"
  db_subnet_group_name              = aws_db_subnet_group.mysql.name
  vpc_security_group_ids            = [aws_security_group.mysql.id]
  deletion_protection               = true
  scaling_configuration {
    auto_pause = true
    max_capacity = 2
    min_capacity = 1
    seconds_until_auto_pause = 3600
  }
}

# Create a subnet group for MySQL
resource "aws_db_subnet_group" "mysql" {
  name       = "mysql"
  subnet_ids = [aws_subnet.private_subnet.id]
}

# Create a security group for MySQL
resource "aws_security_group" "mysql" {
  name_prefix = "mysql"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_subnet.cidr_block]
  }
}


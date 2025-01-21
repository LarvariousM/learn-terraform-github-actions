resource "aws_db_subnet_group" "rds_subnet_group" {
  provider = aws.tokyo
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.tokyo_subnet_private_1a.id, aws_subnet.tokyo_subnet_private_1c.id ]  #if multi AZ add another subnet
}

# resource "aws_security_group" "tokyo_sg" {
#   provider = aws.tokyo
#   name        = "my-db-sg"
#   vpc_id = aws_vpc.tokyo_vpc.id
#   ingress {
#     from_port   = 3306  # MySQL port
#     to_port     = 3306
#     protocol    = "tcp"
#     security_groups = [aws_security_group.sg_for_ec2.id]
#   }
# }

resource "aws_db_instance" "my_db_instance" {
  provider = aws.tokyo
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "dbdatabase"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

    # Attach the DB security group
  vpc_security_group_ids = [aws_security_group.tokyo_sg.id]  
    tags = {
        Name = "ec2_to_mysql_rds"
    }
}

#Creating RDS Instance in the private subnet and security group



#Add Security Rule EC2 Instance to Connect to RDS Instance

# resource "aws_security_group_rule" "ec2_to_db" {
#   type        = "ingress"
#   from_port   = 3306  # MySQL port
#   to_port     = 3306
#   protocol    = "tcp"
#   security_group_id = aws_security_group.sg_for_rds.id  # RDS security group
#   source_security_group_id = aws_security_group.sg_for_ec2.id # EC2 security group
# }

#To get output values: - EC2 Instance, Public IP Address and RDS Entry Point


output "rds-endpoint" {
    value = aws_db_instance.my_db_instance.endpoint
}

output "ec2-publicip"{
    value = aws_instance.ec2.public_ip
}
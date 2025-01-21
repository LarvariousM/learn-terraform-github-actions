provider "aws" {
  region = "ap-northeast-3"
  }


#Creates a New VPC

# resource "aws_vpc" "osaka_vpc" {
#   cidr_block = "10.53.0.0/16"
#   tags = {
#     Name = "EC2-to-RDS-VPC"
#   }
# }

# #Subnets for Public and Private Subnets (Creates a couple of subnets for Multi-Avaibility Zones)

# resource "aws_subnet" "public_subnet" {
#   vpc_id     = aws_vpc.osaka_vpc.id
#   availability_zone = "ap-northeast-3a"
#   cidr_block = "10.53.1.0/24"
#   tags = {
#     Name = "Public Subnet"
#   }
# }

# resource "aws_subnet" "private_subnet_1" {
#   vpc_id     = aws_vpc.osaka_vpc.id
#   cidr_block = "10.53.11.0/24"
#   availability_zone = "ap-northeast-3a"
#   tags = {
#     Name = "Private Subnet-1"
#   }
# }

# # resource "aws_subnet" "private_subnet_2" {
# #   vpc_id     = aws_vpc.osaka_vpc.id
# #   cidr_block = "10.53.13.0/24"
# #   availability_zone = "ap-northeast-3c"
# #   tags = {
# #     Name = "Private Subnet-2"
# #   }
# # }

#Create an Internet Gateway and Attach it to the VPC

# resource "aws_internet_gateway" "ig_2tier" {
#   vpc_id = aws_vpc.osaka_vpc.id

#   tags = {
#     Name = "Internet Gateway for EC2-to-RDS VPC"
#   }
# }

#Create a Route Table and Associate it with the VPC

#public route table with internet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.osaka_vpc.id
  tags = {
    Name = "Public route_table"
  }
}

#public subnet associated with the subnet
resource "aws_route_table_association" "public-route-table-association" {
  subnet_id      = aws_subnet.osaka_subnet_public_3a.id
  route_table_id = aws_route_table.public_route_table.id
}

#routing internet to public subnet
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"  # This is the default route for internet-bound traffic
  gateway_id             = aws_internet_gateway.osaka_igw.id
}


#private route table without internet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.osaka_vpc.id
  tags = {
    Name = "private route_table"
  }
}

#private subnet associated with the subnet
resource "aws_route_table_association" "private-route-table-association" {
  subnet_id      = aws_subnet.osaka_subnet_private_3a.id
  route_table_id = aws_route_table.private_route_table.id
}

# resource "aws_route_table_association" "private-route-table-association-2" {
#   subnet_id      = aws_subnet.tokyo_subnet_private_1d.id
#   route_table_id = aws_route_table.private_route_table.id
# }

#Create EC2 Instance in the public subnet and security group


#creating ec2 instance
resource "aws_instance" "ec2" {
    provider = aws.osaka
    ami = "ami-00dda9c6b6a1e5d93"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.osaka_subnet_private_3c.id
    associate_public_ip_address = true
    key_name = "MyLinuxBox"
    tags = {
        Name = "EC2-for-RDS"
    }
    security_groups = [ aws_security_group.sg_for_ec2.id ]
}

resource "aws_security_group" "sg_for_ec2" {
  name        = "allow_ssh"
  vpc_id      = aws_vpc.osaka_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}


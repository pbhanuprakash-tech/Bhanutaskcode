terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.63.0"
    }
  }
}
provider "aws" {
  
  profile = "default"
}

resource "aws_vpc" "main" {
 cidr_block = var.cidr
 
 tags = {
   Name = "Project VPC"
 }
}

#Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.main.id               # vpc_id will be generated after we create VPC
 }


resource "aws_subnet" "publicsubnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr1
    map_public_ip_on_launch = "true"       //it makes this a public subnet
    availability_zone = "us-east-2a"
    
    tags = {
      Name = "publicsubnet1"
    }
}



resource "aws_subnet" "publicsubnet2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr2
    map_public_ip_on_launch = "true"       //it makes this a public subnet
    availability_zone = "us-east-2a"
    
    tags = {
      Name = "publicsubnet2"
    }
}

resource "aws_subnet" "publicsubnet3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr3
    map_public_ip_on_launch = "true"       //it makes this a public subnet
    availability_zone = "us-east-2a"
    
    tags = {
      Name = "publicsubnet3"
    }
}



resource "aws_subnet" "privatesubnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr4
    map_public_ip_on_launch = "false"       //it makes this a private subnet
    availability_zone = "us-east-2b"
    
    tags = {
      Name = "privatesubnet1"
    }
}

resource "aws_subnet" "privatesubnet2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr5
    map_public_ip_on_launch = "false"       //it makes this a private subnet
    availability_zone = "us-east-2b"
    
    tags = {
      Name = "privatesubnet2"
    }
}

resource "aws_subnet" "privatesubnet3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.cidr6
    map_public_ip_on_launch = "false"       //it makes this a private subnet
    availability_zone = "us-east-2b"
    
    tags = {
      Name = "privatesubnet3"
    }
}

# # Create the route table
# resource "aws_route_table" "route" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.IGW.id
#   }
# }

# Create route table for public subnets
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
   
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# # Associate the public subnets with the route table
resource "aws_route_table_association" "publicsubnet_association_1" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "publicsubnet_association_2" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "public_association_3" {
  subnet_id      = aws_subnet.publicsubnet3.id
  route_table_id = aws_route_table.PublicRouteTable.id
}



# # Create the NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.publicsubnet1.id
}

# # Create the EIP for the NAT gateway
resource "aws_eip" "elasticip" {
  vpc = true
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}




# # Associate the private subnets with the route table
resource "aws_route_table_association" "privatesubnet_association_1" {
  subnet_id      = aws_subnet.privatesubnet1.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route_table_association" "privatesubnet_association_2" {
  subnet_id      = aws_subnet.privatesubnet2.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route_table_association" "privatesubnet_association_3" {
  subnet_id      = aws_subnet.privatesubnet3.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

#Automating the Creation AWS Keypair
resource "tls_private_key" "createkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ec2_key"
  public_key = tls_private_key.createkey.public_key_openssh
}

#Resource to Download Key Pair on Windows
resource "local_file" "local_key_pair" {
  filename = "${var.key_pair_name}.pem"
  file_permission = "0400"
  content = tls_private_key.createkey.private_key_pem
}

resource "null_resource" "savekey"  {
  depends_on = [
    tls_private_key.createkey,
  ]
	provisioner "local-exec" {
	    command = "echo  '${tls_private_key.createkey.private_key_pem}' > ec2_key.pem"
  	}
}
#Creating security group
resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.cidr7]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr7]
  }


}



#Create the instance in public subnet 
resource "aws_instance" "web_instance1" {
  ami           = "ami-08cb13d7a3372171f"
  instance_type = "t2.micro"
  key_name      = "ec2_key"

  subnet_id                   = aws_subnet.publicsubnet1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

}

resource "aws_instance" "web_instance2" {
  ami           = "ami-08cb13d7a3372171f"
  instance_type = "t2.micro"
  key_name      = "ec2_key"

  subnet_id                   = aws_subnet.publicsubnet2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

}

resource "aws_instance" "web_instance3" {
  ami           = "ami-08cb13d7a3372171f"
  instance_type = "t2.micro"
  key_name      = "ec2_key"

  subnet_id                   = aws_subnet.publicsubnet3.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

}

#Create the instance in private subnet
resource "aws_instance" "web_instance4" {
  ami           = "ami-08cb13d7a3372171f"
  instance_type = "t2.micro"
  key_name      = "ec2_key"

  subnet_id                   = aws_subnet.privatesubnet1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

}

resource "aws_instance" "web_instance5" {
  ami           = "ami-08cb13d7a3372171f"
  instance_type = "t2.micro"
  key_name      = "ec2_key"

  subnet_id                   = aws_subnet.privatesubnet2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

}

resource "aws_instance" "web_instance6" {
  ami           = "ami-08cb13d7a3372171f"
  instance_type = "t2.micro"
  key_name      = "ec2_key"

  subnet_id                   = aws_subnet.privatesubnet3.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

}


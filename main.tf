provider "aws" {
  region = "us-east-2"
  
}
/**resource "aws_vpc" "default" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}
resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "172.16.11.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "tf-example2"
  }
}
**/

/**resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.11"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.default.id
}



resource "aws_route_table" "main" {
    vpc_id = aws_vpc.default.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.main.id
}

resource "aws_network_acl" "allowall" {
    vpc_id = aws_vpc.default.id

    egress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
  
}
**/
resource "aws_security_group" "allowall" {
    name = "allowing all for myself testing"
    description = "allow all traffic just for testing"
    #vpc_id = aws_vpc.default.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["107.22.40.20/32"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["18.215.226.36/32"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  

}

resource "aws_eip" "webserver1" {
    instance = aws_instance.webserver1.id
   vpc = true
    #depends_on = ["aws_internet_gateway.main"]
}

resource "aws_key_pair" "default" {
    key_name = "new_key"
    public_key = "Your public SSH key for accessing"
  
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "webserver1" {
  ami = data.aws_ami.ubuntu.id
  availability_zone = "us-west-2a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.default.key_name
  associate_public_ip_address = true

  #vpc_security_group_ids = [aws_security_group.allowall.id]
  #subnet_id = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.allowall.name]
  
}

output "public_ip" {
  value = aws_eip.webserver1.public_ip
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

#resource "aws_db_subnet_group" "default" {
#name = "db subnet"
#subnet_ids = [aws_subnet.my_subnet.id, aws_subnet.my_subnet2.id] 

#}

resource "aws_security_group" "rds" {
   name = "Security group RDS"
   #vpc_id = aws_vpc.default.id

   ingress {
     from_port = 3306
     to_port =  3306
     protocol = "tcp"
     security_groups = [aws_security_group.allowall.id]
   }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
     
 }

resource "aws_db_instance" "default" {
  
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "irfan"
  password             = "MyPassword123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  #db_subnet_group_name = aws_db_subnet_group.default.id
}
 





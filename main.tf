
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

resource "aws_vpc" "My-VPC" {
    cidr_block = var.vpc_cidr
    tags = {
      "Name" = "My-VPC"
    }
}

resource "aws_subnet" "PublicSubnet1" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.My-VPC.id
    availability_zone = "us-east-1a"
    tags = {
      "Name" = "PublicSubnet1"
    }
}

resource "aws_subnet" "PublicSubnet2" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.My-VPC.id
    availability_zone = "us-east-1b"
    tags = {
      "Name" = "PublicSubnet2"
    }
}

resource "aws_subnet" "PrivateSubnet1" {
    cidr_block = "10.0.2.0/24"
    vpc_id = aws_vpc.My-VPC.id
    availability_zone = "us-east-1a" 
    tags = {
        Name = "PrivateSubnet1"
    } 
}

resource "aws_subnet" "PrivateSubnet2" {
    cidr_block = "10.0.3.0/24"
    vpc_id = aws_vpc.My-VPC.id
    availability_zone = "us-east-1b"
    tags = {
      "Name" = "PrivateSubnet2"
    }
}

resource "aws_subnet" "PrivateSubnet3" {
    cidr_block = "10.0.4.0/28"
    vpc_id = aws_vpc.My-VPC.id
    availability_zone = "us-east-1a" 
    tags = {
      "Name" = "PrivateSubnet3"
    }
}

resource "aws_subnet" "PrivateSubnet4" {
    cidr_block = "10.0.5.0/28"
    vpc_id = aws_vpc.My-VPC.id
    availability_zone = "us-east-1b"
    tags = {
      "Name" = "PrivateSubnet4"
    }
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.My-VPC.id 
    tags = {
        Name = "IGW"
    } 
}

resource "aws_eip" "elastic-ip" {
  vpc = true
}

resource "aws_nat_gateway" "NAT" {
    subnet_id = aws_subnet.PublicSubnet1.id 
    allocation_id = aws_eip.elastic-ip.id
    depends_on = [
      aws_internet_gateway.IGW
    ] 
}

resource "aws_route_table" "WebRouteTable" {
    vpc_id = aws_vpc.My-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
  
}

resource "aws_route_table" "AppRouteTable" {
    vpc_id = aws_vpc.My-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.NAT.id
    }  
}

resource "aws_route_table" "DBRouteTable" {
    vpc_id = aws_vpc.My-VPC.id  
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.NAT.id
    }
}

resource "aws_route_table_association" "route_public1" {
    subnet_id = aws_subnet.PublicSubnet1.id
    route_table_id = aws_route_table.WebRouteTable
}

resource "aws_route_table_association" "route_public2" {
    subnet_id = aws_subnet.PublicSubnet2.id
    route_table_id = aws_route_table.WebRouteTable.id
}

resource "aws_route_table_association" "route_private1" {
    subnet_id = aws_subnet.PrivateSubnet1.id
    route_table_id = aws_route_table.AppRouteTable.id
}

resource "aws_route_table_association" "route_private2" {
    subnet_id = aws_subnet.PrivateSubnet2.id
    route_table_id = aws_route_table.AppRouteTable.id
}

resource "aws_route_table_association" "route_private3" {
    subnet_id = aws_subnet.PrivateSubnet3.id
    route_table_id = aws_route_table.DBRouteTable.id
}

resource "aws_route_table_association" "route_private4" {
    subnet_id = aws_subnet.PrivateSubnet4.id
    route_table_id = aws_route_table.DBRouteTable.id
}









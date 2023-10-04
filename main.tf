terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " 5.14.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  access_key = "AKIAX4YPKP2KX6X3MLWQ"
  secret_key = "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"
}

resource "aws_vpc" "my_vpc" {
 cidr_block = "10.20.0.0/16"
 
 tags = {
   Name = "Project VPC"
 }
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.20.1.0/24", "10.20.11.0/24", "10.20.21.0/24"]
}
 
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.my_vpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.my_vpc.id
 
 tags = {
   Name = "Project VPC IG"
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.my_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "My_Route_Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count          = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

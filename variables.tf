variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
  default     = "vpc-05596861f4ecffdeb"
}

variable "private_subnet_ids" {
  default = [
    "subnet-0ee426ba08e9643d9", # itss-ops az1 private
    "subnet-095cdc7b816291369"  # itss-ops az2 private
  ]
}

variable "public_subnet_ids" {
  default = [
    "subnet-02f95b7899e8bed30", # itss-ops az1 public
    "subnet-09c8dbaa942884f5d"  # itss-ops az2 public
  ]
}
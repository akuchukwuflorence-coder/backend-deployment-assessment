variable "my_ip" {
  description = "Your public IPv4 address with /32 CIDR"
  type        = string
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
}
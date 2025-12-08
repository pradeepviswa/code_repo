variable "ami_id" {
  type    = string
  default = ""

}

variable "instance_type" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

variable "key_path" {
  description = "The path to the private key file."
  type        = string
  default     = ""
}

variable "count_vm" {
  type    = number
  default = 1
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 8080, 3000]
}

variable "ansible_user" {
  type        = string
  description = "SSH username for Ansible"
  default     = "ubuntu" # optional
}
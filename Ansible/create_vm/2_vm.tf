module "vm" {
  source        = "git::https://github.com/pradeepviswa/tfmodules.git//vm?ref=main"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  vm_name       = var.vm_name
  key_name      = var.key_name
  key_path      = var.key_path
  count_vm      = var.count_vm
  allowed_ports = var.allowed_ports
  ansible_user  = var.ansible_user
}


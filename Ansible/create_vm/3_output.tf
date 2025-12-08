output "public_ips" {
    value = module.vm.public_ips
}

resource "local_file" "ansible_inventory" {
  filename = "${path.root}/../configure_vm/inventory/hosts.ini"
  content = <<EOF
[webservers]
${join("\n", [
  for ip in module.vm.public_ips :
  "${ip} ansible_user=${module.vm.ansible_user} ansible_ssh_private_key_file=${module.vm.key_path}"
])}
EOF
}

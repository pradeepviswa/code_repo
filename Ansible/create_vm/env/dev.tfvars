ami_id        = "ami-0ecb62995f68bb549"
instance_type = "t3.micro"
vm_name       = "MyServer"
count_vm      = 1
allowed_ports = [22, 80, 8080, 3000]
key_name      = "key_1"
key_path      = "~/.ssh/key_1.pem"
ansible_user  = "ubuntu"


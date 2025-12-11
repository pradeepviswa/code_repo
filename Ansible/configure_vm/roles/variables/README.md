# set location
```
cd code_repo/Ansible/configure_vm 
```

# Run playbook
```
ansible-playbook -i inventory/hosts.ini playbooks/variables.yaml 
```

# pass variabel values from command line
```
ansible-playbook -i inventory/hosts.ini playbooks/variables.yaml -e '{"measure":"gram", "website":test}'
```

# pass variable file name as input 
```
cd code_repo/Ansible/configure_vm 
ansible-playbook -i inventory/hosts.ini playbooks/variables.yaml -e "@roles/variables/vars/input_vars.yaml"
```

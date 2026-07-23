# set location
```
cd code_repo/Ansible/configure_vm 
```

# Run playbook
```
ANSIBLE_LIBRARY=./library ansible-playbook -i inventory/hosts.ini playbooks/custom-module.yaml

or

 export ANSIBLE_LIBRARY="$(pwd)/library"
 ansible-playbook -i inventory/hosts.ini playbooks/custom-module.yaml
```

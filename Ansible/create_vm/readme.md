# switch to root user
```
sudo su
```

# Set AWS credentials as environment variables
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

# Create VM and test ansible code
```
# Navigate to the Terraform create_vm directory
cd create_vm
# Apply Terraform
terraform apply --var-file=env/dev.tfvars -auto-approve
cd ..
cd configure_vm
ansible -i inventory/hosts.ini all --list-hosts
ansible -i inventory/hosts.ini all -m ping 

```

# Destroy VM
```
# be in side root directory
cd ..
cd create_vm
# Destroy Terraform
terraform destroy --var-file=env/dev.tfvars -auto-approve
cd ..
```


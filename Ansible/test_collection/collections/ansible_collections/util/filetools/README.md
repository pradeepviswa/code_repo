## Collection Folder Structure
```
ansible_collections/
└── myorg/
    └── filetools/
        ├── plugins/
        │   └── modules/
        │       └── file_present.py
        └── galaxy.yml
```

## Install collection command
```
ansible-galaxy collection install myorg/filetools/
```

## command output
```
pradeep@Pradeep:/code_repo/ansible/ansible_collection$ ansible-galaxy collection install myorg/filetools/
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'myorg.filetools:1.0.0' to '/home/pradeep/.ansible/collections/ansible_collections/myorg/filetools'
Created collection for myorg.filetools:1.0.0 at /home/pradeep/.ansible/collections/ansible_collections/myorg/filetools
myorg.filetools:1.0.0 was installed successfully
```


## Verify installation
```
ansible-galaxy collection list | grep myorg

output
------
myorg.filetools                          1.0.0
```

## Use the module correctly in a playbook
```
---
- hosts: localhost
  gather_facts: no
  tasks:
    - name: Test collection module
      myorg.filetools.file_present:
        path: /tmp/collection_ok.txt
        content: "Collection works!"
        state: present
```
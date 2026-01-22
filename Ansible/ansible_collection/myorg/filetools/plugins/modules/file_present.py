#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import os

def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=False, default=''),
        state=dict(type='str', choices=['present', 'absent'], default='present')
    )

    result = dict(
        changed=False,
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']
    state = module.params['state']

    if state == 'present':
        if not os.path.exists(path):
            if module.check_mode:
                module.exit_json(changed=True)

            with open(path, 'w') as f:
                f.write(content)

            result['changed'] = True
            result['message'] = 'File created'
        else:
            result['message'] = 'File already exists'

    elif state == 'absent':
        if os.path.exists(path):
            if module.check_mode:
                module.exit_json(changed=True)

            os.remove(path)
            result['changed'] = True
            result['message'] = 'File removed'
        else:
            result['message'] = 'File already absent'

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()

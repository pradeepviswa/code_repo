#!/usr/bin/python3

from ansible.module_utils.basic import AnsibleModule
import subprocess


def run(cmd):
    return subprocess.run(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )


def main():
    module = AnsibleModule(
        argument_spec=dict(
            service=dict(type='str', required=True),
        ),
        supports_check_mode=False
    )

    service = module.params['service']
    changed = False
    messages = []

    # Stop the service
    result = run(f"systemctl stop {service}")

    if result.returncode == 0:
        changed = True
        messages.append(f"Stopped service {service}")
    else:
        messages.append(result.stderr.strip())

    # Find remaining PIDs
    result = run(f"pgrep -f {service}")

    if result.returncode == 0:
        pids = result.stdout.split()

        for pid in pids:
            run(f"kill -9 {pid}")

        changed = True
        messages.append(f"Killed PIDs: {', '.join(pids)}")
    else:
        messages.append("No running processes found")

    module.exit_json(
        changed=changed,
        msg=" | ".join(messages)
    )


if __name__ == '__main__':
    main()

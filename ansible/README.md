# Ansible Configuration for Ainsley Dev Platform

This directory contains Ansible playbooks for deploying and managing platform services.

## Ansible Roles

This project **references** Ansible roles from the WebKit repository instead of copying them:

- `docker` - Install and configure Docker
- `nginx` - Install and configure Nginx web server
- `certbot` - Let's Encrypt SSL certificate management
- `ufw` - Uncomplicated Firewall configuration
- `fail2ban` - Intrusion prevention

The `ansible.cfg` file configures the `roles_path` to point to both local roles and WebKit's roles:
```
roles_path = ./roles:/opt/webkit/platform/ansible/roles
```

The cloud-init script automatically clones the WebKit repository to `/opt/webkit` during VM provisioning, making the roles available for the Ansible playbook.

## Running Playbooks

### Peekaping Deployment

```bash
ansible-playbook -i inventory.ini playbooks/peekaping.yaml \
  -e "domain=peekaping.ainsley.dev" \
  -e "admin_email=hello@ainsley.dev"
```

### Custom Inventory

Create an `inventory.ini` file:
```ini
[peekaping]
peekaping.ainsley.dev ansible_host=YOUR_SERVER_IP ansible_user=root
```

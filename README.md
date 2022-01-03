# Deploy k3s cluster on Proxmox using Terraform and Ansible

With this [Terraform](https://www.terraform.io) plan you can create one or more virtual machines on [Proxmox](https://www.proxmox.com) and install a k3s cluster automatically on it.

## Uses

- [Terraform](https://www.terraform.io)
- [Ansible](https://www.ansible.com)
- [telmate/terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox)
- [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)

## Requirements

1. A template (currently named `debian-11`) within on the Proxmox host (without cloud-init)
2. The `root` password currently set to `Abc1234_`
3. A private and public key stored in your home (`id_rsa` and `id_rsa.pub`)
4. The packages `git` and `ansible` installed

## Usage

```bash
git clone https://github.com/BaldFabi/proxmox-terraform-k3s-ansible-cluster.git
terraform init
terraform plan -out plan.out
terraform apply plan.out
# show the vmids, ip addresses and root passwords
terraform output nodes
```


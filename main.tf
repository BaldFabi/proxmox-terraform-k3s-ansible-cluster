locals {
    count = 3
    public_key = file("~/.ssh/id_rsa.pub")
    k3s_version = "v1.22.5+k3s1"
    k3s_systemd_dir = "/etc/systemd/system"
    root_password = "Abc1234_"
}

resource "random_password" "root_password" {
    count = local.count
    special = true
    length = 20
}

resource "proxmox_vm_qemu" "k3s_node" {
    count = local.count
    name = "node${count.index + 1}"
    target_node = var.proxmox_node
    vmid = "8${count.index+1 < 10 ? "0" : "" }${count.index+1}"

    desc = "k3s cluster node${count.index + 1}\n\nGenerated with Terraform on ${timestamp()}"
    boot = "c"
    agent = 1

    clone = "debian-11"

    memory = 4096
    cores = 2

    lifecycle {
        ignore_changes = [
            desc
        ]
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
	macaddr = "aa:bb:cc:00:00:${count.index < 10 ? "0" : "" }${count.index}"
    }

    disk {
        type = "scsi"
        storage = "local-lvm"
        size = "10G"
    }

    connection {
        type = "ssh"
        user = "root"
        password = local.root_password
        host = self.default_ipv4_address
    }

    provisioner "remote-exec" {
        inline = [
            "hostnamectl set-hostname node${count.index + 1}",
            "echo 'root:${random_password.root_password[count.index].result}' | chpasswd",
            "apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y",
            "mkdir -m 700 ~/.ssh && echo '${local.public_key}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys",
            "history -c",
            "init 6 &",
        ]
    }
}

resource "null_resource" "k3s_installation" {
    triggers = {
        vms_ids = join(",", proxmox_vm_qemu.k3s_node.*.id)
    }

    provisioner "local-exec" {
        command = <<EOT
            git clone https://github.com/k3s-io/k3s-ansible.git
            echo '[master]
${proxmox_vm_qemu.k3s_node[0].default_ipv4_address}

[node]
${join("\n", slice(proxmox_vm_qemu.k3s_node.*.default_ipv4_address, 1, length(proxmox_vm_qemu.k3s_node)))}

[k3s_cluster:children]
master
node' > k3s-ansible/inventory/k3s_nodes.hosts
            ansible-playbook                                                            \
                -i k3s-ansible/inventory/k3s_nodes.hosts                                \
                -u root                                                                 \
                -e k3s_version=${local.k3s_version}                                     \
                -e systemd_dir=${local.k3s_systemd_dir}                                 \
                -e master_ip=${proxmox_vm_qemu.k3s_node[0].default_ipv4_address}        \
                k3s-ansible/site.yml
        EOT
    }
}


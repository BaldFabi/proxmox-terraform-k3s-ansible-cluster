#output "root_passwords" {
#    # use `terraform output root_password` to retrieve the passwords
#    value = [random_password.root_password.*]
#    sensitive = true
#}

#output "vm_ids" {
#    value = [proxmox_vm_qemu.k3s_node.*.id]
#}

output "nodes" {
    value = tomap({
        for i, instance in proxmox_vm_qemu.k3s_node : i => {
            id = instance.id
            ip_address = instance.default_ipv4_address
            root_password = random_password.root_password[i].result
        }
    })
    sensitive = true
}

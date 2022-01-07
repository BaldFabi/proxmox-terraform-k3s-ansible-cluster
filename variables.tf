variable "vm_count" {
    type = number
    default = 3
    description = "The amount of vms that should be created"
}

variable "proxmox_server" {
    type = string
}

variable "proxmox_node" {
    type = string
}

variable "proxmox_username" {
    type = string
}

variable "proxmox_password" {
    type = string
}

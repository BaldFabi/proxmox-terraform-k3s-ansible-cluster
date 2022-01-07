terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.9.4"
        }

        random = {
            source = "hashicorp/random"
            version = "3.1.0"
        }

        null = {
            source = "hashicorp/null"
            version = "3.1.0"
        }
    }
}

provider "proxmox" {
    pm_api_url = "https://${var.proxmox_server}:8006/api2/json"
    pm_user = var.proxmox_username
    pm_password = var.proxmox_password
    pm_tls_insecure = true
}

provider "random" {
}

provider "null" {
}

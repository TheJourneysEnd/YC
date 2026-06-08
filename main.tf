terraform {
  required_providers {
    yandex = {
        source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
    token     = var.yc_token
    cloud_id  = var.yc_cloud_id
    folder_id = var.yc_folder_id
    zone = "ru-central1-a"
}

resource "yandex_vpc_network" "pharmacy_network" {
    name = "pharmacy-network"
}

resource "yandex_vpc_subnet" "pharmacy_subnet" {
    name = "pharmacy-subnet-a"
    zone = "ru-central1-a"
    network_id = yandex_vpc_network.pharmacy_network.id
    v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_security_group" "pharmacy_sg" {
  name        = "pharmacy-security-group"
  network_id  = yandex_vpc_network.pharmacy_network.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 2222
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_compute_disk" "gitea_data_disk" {
    name = "gitea-data-persistent-disk"
    type = "network-hdd"
    zone = "ru-central1-a"
    size = 20

    lifecycle {
        prevent_destroy = true
    }
}

resource "yandex_compute_instance" "pharmacy_vm" {
    name = "pharmacy-vm"
    platform_id = "standart-v3"
    zone = "ru-central1-a"
    service_account_id = var.sa-id

    resources {
        cores = 2
        core_fraction = 20
        memory = 2
    }

    boot_disk {
        initialize_params {
            image_id = "fd80le9bkv3lsbe7934a"
            type = "network-hdd"
            size = 15
        }
    }

    secondary_disk {
        disk_id = yandex_compute_disk.gitea_data_disk.id
        device_name = "data-disk"
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.pharmacy_subnet.id
        nat = true
        security_group_ids = [yandex_vpc_security_group.pharmacy_sg.id]
    }

    metadata = {
        ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
    }
}

output "public_ip" {
  value = yandex_compute_instance.pharmacy_vm.network_interface.0.nat_ip_address
}

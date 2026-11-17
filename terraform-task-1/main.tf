# Пустой VPC
resource "yandex_vpc_network" "hw_network" {
  name = "clopro-homeworks-network"
}


# Публичная подсеть
resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.hw_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


# Приватная подсеть
resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.hw_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private_rt.id
}


# Таблица маршрутизации
# Tnx - https://yandex.cloud/ru/docs/terraform/resources/vpc_route_table
resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.hw_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

# NAT-инстанс
resource "yandex_compute_instance" "nat_instance" {
  name = "nat-instance"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  # Tnx: https://yandex.cloud/ru/docs/terraform/resources/compute_instance
  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet.id
    ip_address = "192.168.10.254" 
    nat        = true                            # чтобы получить внешний адрес
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

}


# Публичная виртуалка
resource "yandex_compute_instance" "jump_host" {
  name = "jump-host"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = true                              # с доступом в инет
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}


# Приватная виртуалка
resource "yandex_compute_instance" "private_vm" {
  name = "private-vm"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
    nat       = false                             # без публичного IP
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

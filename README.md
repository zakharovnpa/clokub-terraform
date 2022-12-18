## Репозиторий с файлами Terraform для выполнения ДЗ 15.1 - 15.4

## ДЗ 15.1. "Организация сети" 

**Внимание!** Домашнее задание и ответы на него расположены в репозитории [05-clokub-homeworks/15.1-Networking](https://github.com/zakharovnpa/05-clokub-homeworks/tree/main/15.1-Networking#readme)

1. Для запуска создания ресурсов в Yandex.Cloud необходимо экспортировать переменные:
```sh
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```
2. В данной конфигурации применены группы безопасности, описание которых дано в разделе 5 этого файла.

### 1. Подключение к провайдеру, сеть и подсети

* main.tf
```tf
# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone      = "ru-central1-a"
}

# Network
resource "yandex_vpc_network" "default" {
  name = "net"
}

#Subnet public
resource "yandex_vpc_subnet" "subnet_pub" {
  name = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

#Subnet private
resource "yandex_vpc_subnet" "subnet_priv" {
  name = "private"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt-a.id  // Привязка таблицы маршрутизации к подсети private
}
```
* variables.tf
```tf
# ID образа ОС Centos-7, собранной с помощью Packer
variable "centos-7-base" {
  default = "fd87ftkus6nii1k3epnu"
}

# ID образа для развертывания шлюза в Интернет с NAT
variable "nat-gw" {
  default = "fd80mrhj8fl2oe87o4e1"
#  default = "fd8o8aph4t4pdisf1fio"  // Другой образ для NAT инстанса
}
```

### 2. Инстансы frontend, backend

* frontend.tf
```tf
#Instance frontend
resource "yandex_compute_instance" "frontend" {
  name                      = "frontend"
  zone                      = "ru-central1-a"
  hostname                  = "frontend.netology.yc"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 1
    core_fraction = "20"
  }

  boot_disk {
    initialize_params {
      image_id    = var.centos-7-base
      name        = "root-frontend"
      type        = "network-hdd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet_pub.id
    nat        = true
    ip_address = "192.168.10.11"
  }

  scheduling_policy {
    preemptible = true  // Прерываемая ВМ

  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

* backend.tf
```tf
#Instance backend
resource "yandex_compute_instance" "backend" {
  name                      = "backend"
  zone                      = "ru-central1-b"
  hostname                  = "backend.netology.yc"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 1
    core_fraction = "20"
  }

  boot_disk {
    initialize_params {
      image_id    = var.centos-7-base
      name        = "root-backend"
      type        = "network-hdd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet_priv.id
    nat        = false
    ip_address = "192.168.20.11"
  }

  scheduling_policy {
    preemptible = true  // Прерываемая ВМ

  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}
```


### 3. Инстанс NAT шлюза в Интернет

* natgw.tf
```tf
#Instance natgw
resource "yandex_compute_instance" "natgw" {
  name                      = "natgw"
  zone                      = "ru-central1-a"
  hostname                  = "natgw.netology.yc"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 1
    core_fraction = "20"
  }

  boot_disk {
    initialize_params {
      image_id    = var.nat-gw
      name        = "root-natgw"
      type        = "network-hdd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.subnet_pub.id
    security_group_ids = [yandex_vpc_security_group.natgw.id]  # привязка группы безопасности к интерфейсу инстанса
    nat            = true
    ip_address = "192.168.10.254"
  }

  scheduling_policy {
    preemptible = true  // Прерываемая ВМ

  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

### 4. Таблица маршрутизации, связанной с подсетью private
* routetable.tf
```tf
#Route table
resource "yandex_vpc_route_table" "rt-a" {
  network_id = "${yandex_vpc_network.default.id}"

  static_route {
    
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.natgw.network_interface.0.ip_address   // Адрес NAT инстанса
  }
}
```
### 5. Безопасность в сети. 
Группа безопасности в тестовом режиме разрешает для NAT инстанса любой трафик в направлении сетей public и private.

 
* securitygroup.tf
```tf
#Security group
resource "yandex_vpc_security_group" "natgw" {
  name        = "Security group for NAt-instance"
  description = "Traffic instance NAT"
  network_id  = "${yandex_vpc_network.default.id}"

  labels = {
    my-label = "my-label-value"
  }

  ingress {
    protocol       = "TCP"
    description    = "secure shell from Internet to natgw"
    v4_cidr_blocks = ["0.0.0.0/0"]      # для всех адресов
    port        = 22                    # for ssh
  }

  egress {
    protocol       = "ANY"                    # любые протоклоы
    description    = "from natgw to frontend and backup"
    v4_cidr_blocks = ["192.168.10.11/32", "192.168.20.11/32"]            # только для адресов fronend и backend
    port      = -1                            # все номера портов
  }
}
```

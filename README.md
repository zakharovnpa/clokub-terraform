# Репозиторий с файлами Terraform для выполнения ДЗ 15.1 - 15.4

## ДЗ 15.1. "Организация сети" 
> Для запуска создания ресурсов в Yandex.Cloud необходимо заменить пустой файл `key.json` на файл с параметрами актуальной УЗ, а также в файле `variables.tf` добавить ID своего облака и Folder своего облака.

### 1. Подключение к провайдеру, сеть и подсети

* key.json
  * ИСпользовать файл для своей УЗ

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
  service_account_key_file = "key.json"
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
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
  route_table_id = yandex_vpc_route_table.rt-a.id
}

```

* variables.tf
```tf
# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = ""
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = ""
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "centos-7-base" {
  default = "fd87ftkus6nii1k3epnu"
}

# ID образа для развертывания шлюза в Интернет с NAT
variable "nat-gw" {
  default = "fd80mrhj8fl2oe87o4e1"
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
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = var.centos-7-base
      name        = "root-frontend"
      type        = "network-nvme"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet_pub.id
    nat        = true
    ip_address = "192.168.10.11"
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
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = var.centos-7-base
      name        = "root-backend"
      type        = "network-nvme"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet_priv.id
    nat        = false
    ip_address = "192.168.20.11"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

### 3. Инстанс NAT

* natgw.tf
```tf
Instance natgw
resource "yandex_compute_instance" "natgw" {
  name                      = "natgw"
  zone                      = "ru-central1-a"
  hostname                  = "natgw.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = var.nat-gw
      name        = "root-natgw"
      type        = "network-nvme"
      size        = "10"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.subnet_pub.id
    nat            = true
    ip_address = "192.168.10.254"
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
    next_hop_address   = yandex_compute_instance.natgw.network_interface.0.ip_address
  }
}
```
### 5. Ограничение доступа по сети (Security group) для NAT инстанса

* securitygroup.tf
```tf
##Security group
resource "yandex_vpc_security_group" "natgw" {
  name        = "Security group for NAt-instance"
  description = "Traffic instance NAT"
  network_id  = "${yandex_vpc_network.default.id}"

  labels = {
    my-label = "my-label-value"
  }

  ingress {
    protocol       = "ANY"
    description    = "from frontend and backup to natgw"
    v4_cidr_blocks = ["192.168.10.11/32", "192.168.20.11/32"]
    port           = -1
  }

  egress {
    protocol       = "ANY"
    description    = "from natgw to frontend and backup"
    v4_cidr_blocks = ["192.168.10.11/32", "192.168.20.11/32"]
    port      = -1
  }
}
```


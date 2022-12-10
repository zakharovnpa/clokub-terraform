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


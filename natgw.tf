#Instance natgw
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
#      image_id    = "${var.nat-gw}"
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

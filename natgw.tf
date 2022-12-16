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
#      image_id    = "${var.nat-gw}"
      name        = "root-natgw"
#      type        = "network-nvme"
      type        = "network-hdd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.subnet_pub.id
#    security_group_ids = yandex_compute_instance.natgw.id  // отключено, т.к. получаем ошибку
    nat            = true
    ip_address = "192.168.10.254"
  }

  scheduling_policy {
    preemptible = true

  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}

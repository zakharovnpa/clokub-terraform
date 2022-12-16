#Security group
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
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = -1
  }

  egress {
    protocol       = "ANY"
    description    = "from natgw to frontend and backup"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port      = -1
  }
}

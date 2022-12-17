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
    description    = "from Internet to natgw"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port        = 22
  }

  egress {
    protocol       = "ANY"
    description    = "from natgw to frontend and backup"
    v4_cidr_blocks = ["192.168.10.11/32", "192.168.20.11/32"]
    port      = -1
  }

}

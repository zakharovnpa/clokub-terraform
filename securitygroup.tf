#Security group
resource "yandex_vpc_security_group" "group1" {
  name        = "My security group"
  description = "description for my security group"
  network_id  = "${yandex_vpc_network.default.id}"

  labels = {
    my-label = "my-label-value"
  }

  ingress {
    protocol       = "ANY"
    description    = "rule1 description"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = -1
  }
#
#  egress {
#    protocol       = "ANY"
#    description    = "rule2 description"
#    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
#    from_port      = 8090
#    to_port        = 8099
#  }
#
#  egress {
#    protocol       = "UDP"
#    description    = "rule3 description"
#    v4_cidr_blocks = ["10.0.1.0/24"]
#    from_port      = 8090
#    to_port        = 8099
#  }
}

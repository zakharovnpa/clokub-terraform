output "natgw_wan_ip" {     # вывод на зкран ip адрес NAT-gw инстанса
  description = "WAN IP address NAT-gw instance"
  value = yandex_compute_instance.natgw.network_interface.0.nat_ip_address
}

output "natgw_lan_ip" {     # вывод на зкран ip адрес NAT-gw инстанса
  description = "LAN IP address NAT-gw instance"
  value = yandex_compute_instance.natgw.network_interface.0.ip_address
}

output "frontend_wan_ip" {     # вывод на зкран WAN ip адресf Frontend инстанса
  description = "WAN IP address Frontend instance"
  value = yandex_compute_instance.frontend.network_interface.0.nat_ip_address
}

output "frontend_lan_ip" {     # вывод на зкран LAN ip адреса Frontend инстанса
  description = "LAN IP address Frontend instance"
  value = yandex_compute_instance.frontend.network_interface.0.ip_address
}


output "backend_wan_ip" {     # вывод на зкран WAN ip адресf Backend инстанса
  description = "WAN IP address Backend instance"
  value = yandex_compute_instance.backend.network_interface.0.nat_ip_address
}

output "backend_lan_ip" {     # вывод на зкран LAN ip адреса Backend инстанса
  description = "LAN IP address Backend instance"
  value = yandex_compute_instance.backend.network_interface.0.ip_address
}


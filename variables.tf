# ID облака
variable "yandex_cloud_id" {
  default = "$YC_CLOUD_ID"
}

# Token
#variable "yc_token"
#  default = "$YC_TOKEN"

# Заменить на ID Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gd3hm4niaifoa8dahm"
}

# ID образа для развертывания инстанс frontend и backup
variable "centos-7-base" {
  default = "fd87ftkus6nii1k3epnu"
}

# ID образа для развертывания шлюза в Интернет с NAT
variable "nat-gw" {
  default = "fd80mrhj8fl2oe87o4e1"
#  default = "fd8o8aph4t4pdisf1fio"
}


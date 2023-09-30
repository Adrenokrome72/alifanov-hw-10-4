# Сеть и подсети.

resource "yandex_vpc_network" "servernet" {
  name = "servernet"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "web1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.servernet.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "web2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.servernet.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "monitor"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.servernet.id
  v4_cidr_blocks = ["192.168.3.0/24"]
}

resource "yandex_vpc_subnet" "subnet-4" {
  name           = "log"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.servernet.id
  v4_cidr_blocks = ["192.168.4.0/24"]
}

resource "yandex_vpc_subnet" "subnet-5" {
  name           = "public"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.servernet.id
  v4_cidr_blocks = ["192.168.5.0/24"]
}

# Группы безопасности

resource "yandex_vpc_security_group" "web" {
  name        = "web"
  description = "security group"
  network_id  = "${yandex_vpc_network.servernet.id}"

  ingress {
    protocol = "ANY"
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24"]
    port = 80
  }
  
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24"]
    port = 80
  }
}

resource "yandex_vpc_security_group" "grafana" {
  name        = "grafana"
  description = "grafana group"
  network_id  = "${yandex_vpc_network.servernet.id}"

  ingress {
    protocol = "ANY"
    v4_cidr_blocks = ["192.168.5.0/24"]
    port = 3000
  }
  
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["192.168.5.0/24"]
    port = 3000
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name        = "kibana"
  description = "kibana group"
  network_id  = "${yandex_vpc_network.servernet.id}"

  ingress {
    protocol = "ANY"
    v4_cidr_blocks = ["192.168.5.0/24"]
    port = 5601
  }
  
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["192.168.5.0/24"]
    port = 5601
  }
}

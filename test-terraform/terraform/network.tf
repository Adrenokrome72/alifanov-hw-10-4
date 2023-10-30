# VPC 
resource "yandex_vpc_network" "vpcnet" {
  name = "net_project"
}

resource "yandex_vpc_route_table" "in-to-ext" {
  network_id = yandex_vpc_network.vpcnet.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion.network_interface.0.ip_address
  }
}


# subnets 
resource "yandex_vpc_subnet" "web-1" {
  name           = "web-1-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpcnet.id
  v4_cidr_blocks = ["192.168.1.0/24"]
  route_table_id = yandex_vpc_route_table.in-to-ext.id
}

resource "yandex_vpc_subnet" "web-2" {
  name           = "web-2-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpcnet.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.in-to-ext.id
}

resource "yandex_vpc_subnet" "in-services" {
  name           = "in-services-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpcnet.id
  v4_cidr_blocks = ["192.168.3.0/24"]
  route_table_id = yandex_vpc_route_table.in-to-ext.id
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpcnet.id
  v4_cidr_blocks = ["192.168.4.0/24"]
}


#target_group 
resource "yandex_alb_target_group" "target_group" {
  name = "target-group"

  target {
    ip_address = yandex_compute_instance.web-1.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.in-web-1.id
  }

  target {
    ip_address = yandex_compute_instance.web-2.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.in-web-2.id
  }
}


# backend_group

resource "yandex_alb_backend_group" "alb" {
  name = "backend-group"

  http_backend {
    name             = "http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.target_group.id]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}


# HTTP router
resource "yandex_alb_http_router" "router" {
  name = "http-router"
}

resource "yandex_alb_virtual_host" "root" {
  name           = "root-virtual-host"
  http_router_id = yandex_alb_http_router.router.id
  route {
    name = "root-path"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb.id
        timeout          = "3s"
      }
    }
  }
}


# L7 balancer

resource "yandex_alb_load_balancer" "lb" {
  name               = "load-balancer"
  network_id         = yandex_vpc_network.vpcnet.id
  security_group_ids = [yandex_vpc_security_group.load-balancer.id, yandex_vpc_security_group.in.id] 

  allocation_policy {
    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.in-services.id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}


# security_group
resource "yandex_vpc_security_group" "security" {
  name       = "security"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion" {
  name       = "public-bastion"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana" {
  name       = "public-grafana"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-kibana" {
  name       = "public-kibana"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-load-balancer" {
  name       = "public-load-balancer"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

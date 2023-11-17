# network with subnets
 
 resource "yandex_vpc_network" "vpcnet" {
   name = "net"
 }
 # Подсеть web1
 resource "yandex_vpc_subnet" "subnet1" {
   name           = "subnet1"
   zone           = "ru-central1-a"
   network_id     = yandex_vpc_network.vpcnet.id
   v4_cidr_blocks = ["192.168.1.0/24"]
   route_table_id = yandex_vpc_route_table.route_table.id
 }
 # Подсеть web2
 resource "yandex_vpc_subnet" "subnet2" {
   name           = "subnet2"
   zone           = "ru-central1-b"
   network_id     = yandex_vpc_network.vpcnet.id
   v4_cidr_blocks = ["192.168.2.0/24"]
   route_table_id = yandex_vpc_route_table.route_table.id
 }
# Подсеть services
resource "yandex_vpc_subnet" "subnet3" {
  name           = "subnet3"
  v4_cidr_blocks = ["192.168.3.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpcnet.id
  route_table_id = yandex_vpc_route_table.route_table.id
}
# Подсеть public
resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  description    = "subnet for bastion"
  v4_cidr_blocks = ["192.168.4.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpcnet.id
}

#nat-gateway

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "my-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  network_id = yandex_vpc_network.vpcnet.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

#security group

 resource "yandex_vpc_security_group" "private-sg" {
  name       = "private-sg"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol          = "TCP"
    description       = "allow loadbalancer_healthchecks incoming connections"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "allow any connection from subnets"
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_vpc_security_group" "load-balancer-sg" {
  name       = "load-balancer-sg"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP incoming connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow any ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion-sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "TCP"
    description    = "allow any ssh incoming connections" 
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow any ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana-sg" {
  name       = "grafana-sg"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "TCP"
    description    = "allow grafana incoming connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow any ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana-sg" {
  name       = "kibana-sg"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol       = "TCP"
    description    = "allow kibana incoming connections"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow any ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elasticsearch-sg" {
  name        = "elasticsearch-sg"
  description = "Elasticsearch security group"
  network_id = yandex_vpc_network.vpcnet.id

  ingress {
    protocol          = "TCP"
    description       = "Rule for kibana"
    security_group_id = yandex_vpc_security_group.kibana-sg.id
    port              = 9200
  }

  ingress {
    protocol          = "TCP"
    description       = "Rule for web"
    security_group_id = yandex_vpc_security_group.private-sg.id
    port              = 9200
  }

  ingress {
    protocol          = "TCP"
    description       = "Rule for bastion ssh"
    security_group_id = yandex_vpc_security_group.bastion-sg.id
    port              = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Rule out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#nginx-1 vm

 resource "yandex_compute_instance" "vm1" {
   name                      = "web1"
   hostname                  = "web1"
   zone                      = "ru-central1-a"
   
   resources {
     core_fraction = 20
     cores         = 2
     memory        = 2
   }
 
   boot_disk {
     initialize_params {
       image_id = "fd8irgqv3b16i3rv20ip"
     }
   }
 
   network_interface {
     subnet_id  = yandex_vpc_subnet.subnet1.id
     security_group_ids = [yandex_vpc_security_group.private-sg.id]
     ip_address = "192.168.1.10"
   }
 
   metadata = {
     user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
   }
 }
 
 output "internal_ip_address_web1-nginx1" {
   value = yandex_compute_instance.vm1.network_interface.0.ip_address
 }

#nginx-2 vm

 resource "yandex_compute_instance" "vm2" {
   name                      = "web2"
   hostname                  = "web2"
   zone                      = "ru-central1-b"
 
   resources {
     core_fraction = 20
     cores         = 2
     memory        = 2
   }
 
   boot_disk {
     initialize_params {
       image_id = "fd8irgqv3b16i3rv20ip"
     }
   }
 
   network_interface {
     subnet_id  = yandex_vpc_subnet.subnet2.id
     security_group_ids = [yandex_vpc_security_group.private-sg.id]
     ip_address = "192.168.2.10"
   }
 
   metadata = {
     user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
   }
 }
 
 output "internal_ip_address_web2-nginx2" {
   value = yandex_compute_instance.vm2.network_interface.0.ip_address
 }

#prometheus vm
 
 resource "yandex_compute_instance" "vm3" {
   name                      = "prometheus"
   hostname                  = "prometheus"
   zone                      = "ru-central1-c"
  
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
   }
 
   boot_disk {
     initialize_params {
       image_id = "fd8irgqv3b16i3rv20ip"
     }
   }
 
   network_interface {
     subnet_id  = yandex_vpc_subnet.subnet3.id
     security_group_ids = [yandex_vpc_security_group.private-sg.id]
     ip_address = "192.168.3.30"
   }
   
   metadata = {
     user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
   }
 }
 
 output "internal_ip_address_prometheus" {
   value = yandex_compute_instance.vm3.network_interface.0.ip_address
 }

#elasticsearch vm

 resource "yandex_compute_instance" "vm4" {
   name                      = "elasticsearch"
   hostname                  = "elasticsearch"
   zone                      = "ru-central1-c"
 
   resources {
     core_fraction = 20
     cores         = 4
     memory        = 8
    }
 
    boot_disk {
      initialize_params {
        image_id = "fd8irgqv3b16i3rv20ip"
      }
    }
    
    network_interface {
     subnet_id  = yandex_vpc_subnet.subnet3.id
     security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.elasticsearch-sg.id]
     ip_address = "192.168.3.40"
    }
    
    metadata = {
      user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
    }
 }
 
 output "internal_ip_address_elasticsearch" {
   value = yandex_compute_instance.vm4.network_interface.0.ip_address
 }

#grafana vm

 resource "yandex_compute_instance" "vm5" {
   name                      = "grafana"
   hostname                  = "grafana"
   zone                      = "ru-central1-c"
   
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
   }
 
   boot_disk {
     initialize_params {
       image_id = "fd8irgqv3b16i3rv20ip"
     }
   }
 
   network_interface {
     subnet_id          = yandex_vpc_subnet.public-subnet.id
     ip_address         = "192.168.4.50"
     nat                = true
     security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.grafana-sg.id]
   }
 
   metadata = {
     user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
   }
 }
 
 output "internal_ip_address_grafana" {
   value = yandex_compute_instance.vm5.network_interface.0.ip_address
 }
 
 output "external_ip_address_grafana" {
   value = yandex_compute_instance.vm5.network_interface.0.nat_ip_address
 }
 
#kibana vm

 resource "yandex_compute_instance" "vm6" {
   name                      = "kibana"
   hostname                  = "kibana"
   zone                      = "ru-central1-c"
   
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
   }
 
   boot_disk {
     initialize_params {
       image_id = "fd8irgqv3b16i3rv20ip"
     }
   }
 
   network_interface {
     subnet_id          = yandex_vpc_subnet.public-subnet.id
     ip_address         = "192.168.4.60"
     nat                = true
     security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.kibana-sg.id]
   }
 
   metadata = {
     user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
   }
 }
 
 output "internal_ip_address_kibana" {
   value = yandex_compute_instance.vm6.network_interface.0.ip_address
 }
 
 output "external_ip_address_kibana" {
   value = yandex_compute_instance.vm6.network_interface.0.nat_ip_address
 }
 
#bastion vm

 resource "yandex_compute_instance" "vm7" {
   name                      = "bastion"
   hostname                  = "bastion"
   zone                      = "ru-central1-c"
   
  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
   }
 
   boot_disk {
     initialize_params {
       image_id = "fd8irgqv3b16i3rv20ip"
     }
   }
 
   network_interface {
     subnet_id          = yandex_vpc_subnet.subnet1.id
     ip_address         = "192.168.4.70"
     nat                = true
     security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
   }
 
   metadata = {
     user-data = "${file("/home/alifanov/alifanov-sys-diplom/test-terraform/terraform/meta.yaml")}"
   }
 }
 
 output "internal_ip_address_bastion" {
   value = yandex_compute_instance.vm7.network_interface.0.ip_address
 }
 
 output "external_ip_address_bastion" {
   value = yandex_compute_instance.vm7.network_interface.0.nat_ip_address
 }

#target group

resource "yandex_alb_target_group" "target" {
  name           = "target-group"

  target {
    subnet_id    = yandex_vpc_subnet.subnet1.id
    ip_address   = yandex_compute_instance.vm1.network_interface.0.ip_address
  }

  target {
    subnet_id    = yandex_vpc_subnet.subnet2.id
    ip_address   = yandex_compute_instance.vm2.network_interface.0.ip_address
  }
}


resource "yandex_alb_backend_group" "backend-group" {
  name                     = "backend-group"
  session_affinity {
    connection {
    source_ip = false
    }
  }

  http_backend {
    name                   = "backend-group"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.target.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

#http-router

resource "yandex_alb_http_router" "router" {
  name = "router"
}

resource "yandex_alb_virtual_host" "router-host" {
  name           = "router-host"
  http_router_id = yandex_alb_http_router.router.id
  route {
    name = "route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "3s"
      }
    }
  }
}

#balancer

resource "yandex_alb_load_balancer" "balancer" {
  name        = "balancer"
  network_id  = yandex_vpc_network.vpcnet.id
  security_group_ids = [yandex_vpc_security_group.load-balancer-sg.id, yandex_vpc_security_group.private-sg.id]
  
  allocation_policy {
    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.subnet3.id   
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}
output "external_ip_address_balancer" {
   value = yandex_alb_load_balancer.balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
 }

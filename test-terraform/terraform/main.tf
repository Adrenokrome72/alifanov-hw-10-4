# network with subnets
 
 resource "yandex_vpc_network" "vpcnet" {
   name = "net"
 }
 
 resource "yandex_vpc_subnet" "subnet1" {
   name           = "subnet1"
   zone           = "ru-central1-a"
   network_id     = yandex_vpc_network.vpcnet.id
   v4_cidr_blocks = ["192.168.1.0/24"]
 }
 
 resource "yandex_vpc_subnet" "subnet2" {
   name           = "subnet2"
   zone           = "ru-central1-b"
   network_id     = yandex_vpc_network.vpcnet.id
   v4_cidr_blocks = ["192.168.2.0/24"]
 }
 
#security group

 resource "yandex_vpc_security_group" "security" {
   name        = "security"
   network_id  = yandex_vpc_network.vpcnet.id
 
   ingress {
     protocol       = "TCP"
     description    = "grafana"
     v4_cidr_blocks = ["0.0.0.0/0"]
     port           = 3000
   }
 
   ingress {
     protocol       = "TCP"
     description    = "kibana"
     v4_cidr_blocks = ["0.0.0.0/0"]
     port           = 5601
   }
   
   ingress {
     protocol       = "TCP"
     description    = "app load balancer"
     v4_cidr_blocks = ["0.0.0.0/0"]
     port           = 80
   }
   
   ingress {
     protocol       = "TCP"
     description    = "SSH-permission"
     v4_cidr_blocks = ["192.168.0.0/16"]
     port           = 22
   }
   
   
   egress {
     protocol       = "ANY"
     v4_cidr_blocks = ["0.0.0.0/0"]
     from_port      = 0
     to_port        = 65535
   }
 }
 
 resource "yandex_vpc_security_group" "bastion" {
   name        = "bastion"
   network_id  = yandex_vpc_network.vpcnet.id
 
   ingress {
     protocol       = "TCP"
     description    = "bastion"
     v4_cidr_blocks = ["0.0.0.0/0"]
     port           = 22
   }
 
   egress {
     protocol       = "ANY"
     v4_cidr_blocks = ["0.0.0.0/0"]
     from_port      = 0
     to_port        = 65535
   }
 }

#nginx-1 vm

 resource "yandex_compute_instance" "vm1" {
   name                      = "web1"
   hostname                  = "web1"
   zone                      = "ru-central1-a"
   allow_stopping_for_update = true
   
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
     ip_address = "192.168.1.10"
	 nat        = false
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
   allow_stopping_for_update = true
 
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
	 ip_address = "192.168.2.10"
     nat        = false
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
   zone                      = "ru-central1-a"
   allow_stopping_for_update = true
  
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
     ip_address = "192.168.1.11"
     nat        = false
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
   zone                      = "ru-central1-a"
   allow_stopping_for_update = true
 
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
	 ip_address = "192.168.1.12"
     nat        = false
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
   zone                      = "ru-central1-a"
   allow_stopping_for_update = true
   
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
     ip_address         = "192.168.1.13"
     nat                = true
     security_group_ids = [yandex_vpc_security_group.security.id]
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
   zone                      = "ru-central1-a"
   allow_stopping_for_update = true
   
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
     ip_address         = "192.168.1.14"
     nat                = true
     security_group_ids = [yandex_vpc_security_group.security.id]
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
   zone                      = "ru-central1-a"
   allow_stopping_for_update = true
   
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
     ip_address         = "192.168.1.15"
     nat                = true
     security_group_ids = [yandex_vpc_security_group.bastion.id]
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

resource "yandex_alb_http_router" "tf-router" {
  name          = "router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "vm-main"
  http_router_id          = yandex_alb_http_router.tf-router.id
  route {
    name                  = "main"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.backend-group.id
        timeout           = "60s"
      }
    }
  }
}

#balancer

resource "yandex_alb_load_balancer" "balancer" {
  name        = "balancer"
  network_id  = yandex_vpc_network.vpcnet.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet1.id   
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
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}

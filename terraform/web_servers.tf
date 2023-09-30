# Web-servers

resource "yandex_compute_instance" "web1" {

  zone = "ru-central1-a"
  name = "web1"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./web.yaml")}"
  }
}

resource "yandex_compute_instance" "web2" {

  zone = "ru-central1-b"
  name = "web2"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./web.yaml")}"
  }
}

# Target-groups

resource "yandex_alb_target_group" "web" {
  name = "web"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address   = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    ip_address   = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "web-servers" {
  http_backend {
    name = "web-servers"
    target_group_ids = ["${yandex_alb_target_group.web.id}"]
    port = 80
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

#Router

resource "yandex_alb_http_router" "router" {
  name = "web-servers-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name = "web-servers-router-virtual-host"
  http_router_id = yandex_alb_http_router.router.id
  route {
    name = "router"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-servers.id
      }
    }
  }
}

#Balancer

resource "yandex_alb_load_balancer" "app-lb" {
  name = "app-lb"
  network_id = yandex_vpc_network.servernet.id

  allocation_policy {
    location {
      zone_id = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-5.id
    }
  }
  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ "80" ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}

output "web1" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
} 

output "web2" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
} 

output "load_balancer_pub" {
  value = yandex_alb_load_balancer.app-lb.listener[0].endpoint[0].address[0].external_ipv4_address
} 

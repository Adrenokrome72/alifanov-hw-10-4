# web-site

resource "yandex_compute_instance" "web-1" {
  name        = "vm-web-1"
  hostname    = "web-1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.web-1.id
    security_group_ids = [yandex_vpc_security_group.security.id]
    ip_address         = "192.168.1.5"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

resource "yandex_compute_instance" "web-2" {
  name        = "vm-web-2"
  hostname    = "web-2"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip" 
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.web-2.id
    security_group_ids = [yandex_vpc_security_group.security.id]
    ip_address         = "192.168.2.5"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}


# bastion
resource "yandex_compute_instance" "bastion" {
  name        = "vm-bastion"
  hostname    = "bastion"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip" 
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.security.id, yandex_vpc_security_group.bastion.id]
    ip_address         = "192.168.4.5"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}


# prometheus 
resource "yandex_compute_instance" "prometheus" {
  name        = "vm-prometheus"
  hostname    = "prometheus"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip" 
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.in-services.id
    security_group_ids = [yandex_vpc_security_group.security.id]
    ip_address         = "192.168.3.5"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}


# grafana 
resource "yandex_compute_instance" "grafana" {
  name        = "vm-grafana"
  hostname    = "grafana"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip" 
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.security.id, yandex_vpc_security_group.grafana.id]
    ip_address         = "192.168.4.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}


# elastic 
resource "yandex_compute_instance" "elastic" {
  name        = "vm-elastic"
  hostname    = "elastic"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip" 
      size     = 6
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.in-services.id
    security_group_ids = [yandex_vpc_security_group.security.id]
    ip_address         = "192.168.3.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

# kibana 
resource "yandex_compute_instance" "kibana" {
  name        = "vm-kibana"
  hostname    = "kibana"
  zone        = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8irgqv3b16i3rv20ip" 
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.security.id, yandex_vpc_security_group.public-kibana.id]
    ip_address         = "192.168.4.15"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

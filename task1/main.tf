# Віртуальна приватна хмара (VPC)
resource "digitalocean_vpc" "exam_vpc" {
  name     = "${var.last_name}-vpc" 
  region   = "fra1" 
  ip_range = "10.10.10.0/24" # Діапазон IP-адрес [cite: 8]
}


# Віртуальна машина (Node)
resource "digitalocean_droplet" "exam_node" {
  name     = "${var.last_name}-node"
  region   = digitalocean_vpc.exam_vpc.region
  size     = "s-2vcpu-4gb"
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.exam_vpc.id

  # Скрипт для налаштування пароля при запуску
  user_data = <<-EOF
              #!/bin/bash
              echo "root:${var.root_password}" | chpasswd
              sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
              sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
              systemctl restart ssh
              EOF
}

# Налаштування фаєрволу
resource "digitalocean_firewall" "exam_firewall" {
  name = "${var.last_name}-firewall" 
  droplet_ids = [digitalocean_droplet.exam_node.id]

  # Вхідні підключення [cite: 12]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000-8003" # Об'єднані порти 8000, 8001, 8002, 8003
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Вихідні підключення: порти 1-65535 [cite: 13]
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Сховище для об'єктів (Бакет)
resource "digitalocean_spaces_bucket" "exam_bucket" {
  name   = "${var.last_name}-bucket-task-1" 
  region = digitalocean_vpc.exam_vpc.region # Регіон ідентичний до VPC [cite: 21]
  # Тип сховища за замовчуванням (додаткові ACL не вказуються) [cite: 20]
}

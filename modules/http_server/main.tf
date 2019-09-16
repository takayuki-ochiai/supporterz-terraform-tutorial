variable "server_name" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "instance_type" {
  default = "t3.micro"
}

data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  // セキュリティグループはsecurity_groupsではなくvpc_security_group_idsで設定すること
  // さもないとセキュリティグループの設定を追加した時にインスタンス削除→再構築されてしまう
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd.service
EOF

  tags = {
    Name      = "${var.server_name}"
    ManagedBy = "Terraform"
  }
}

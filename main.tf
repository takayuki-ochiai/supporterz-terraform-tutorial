resource "aws_vpc" "terraform_example_vpc" {
  cidr_block = "10.0.0.0/16"

  // AWS の DNS サーバによる名前解決を有効にする
  enable_dns_support = true

  // trueにするとこのVPC内部のリソースにパブリックDNSホスト名が自動で割り当てられる
  enable_dns_hostnames = true

  tags = {
    Name      = "terraform-example-vpc"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_0" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.terraform_example_vpc.id

  // このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てる
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name      = "public-0"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_1" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.terraform_example_vpc.id

  // このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てる
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name      = "public-1"
    ManagedBy = "Terraform"
  }
}

resource "aws_internet_gateway" "terraform_example_igw" {
  vpc_id = aws_vpc.terraform_example_vpc.id

  tags = {
    Name      = "terraform-sandbox-igw"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform_example_vpc.id

  tags = {
    Name      = "terraform-public"
    ManagedBy = "Terraform"
  }
}

// 先ほど作成したルートテーブルに対してレコードを挿入する
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.terraform_example_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// サブネットにルートテーブルを関連づけする
resource "aws_route_table_association" "public_0" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_0.id
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_1.id
}

// セキュリティグループの設定
resource "aws_security_group" "terraform_example" {
  name   = "terraform-example-security-group"
  vpc_id = aws_vpc.terraform_example_vpc.id

  tags = {
    Name      = "example"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group_rule" "ingress_rule" {
  // インバウンドルールの追加
  type = "ingress"

  // ポート範囲を指定
  from_port = 80
  to_port   = 80

  // プロトコルの指定
  protocol          = "tcp"
  security_group_id = aws_security_group.terraform_example.id

  // 許可するトラフィックのIP範囲をCIDRで指定
  cidr_blocks = ["0.0.0.0/0"]
}

// 全てのアウトバウンドトラフィックを許可する
resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.terraform_example.id
  cidr_blocks       = ["0.0.0.0/0"]
}

module "http_server_0" {
  source            = "./modules/http_server"
  server_name       = "http-server-0"
  subnet_id         = aws_subnet.public_0.id
  security_group_id = aws_security_group.terraform_example.id
}

module "http_server_1" {
  source            = "./modules/http_server"
  server_name       = "http-server-1"
  subnet_id         = aws_subnet.public_1.id
  security_group_id = aws_security_group.terraform_example.id
}

resource "aws_elb" "terrafrom_example_elb" {
  name = "terraform-example-elb"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval = 30
  }

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id,
  ]

  security_groups = [
    aws_security_group.terraform_example.id,
  ]

  instances = [
    module.http_server_0.ec2_instance_id,
    module.http_server_1.ec2_instance_id,
  ]

  tags = {
    Name      = "foobar-terraform-elb"
    ManagedBy = "Terraform"
  }
}


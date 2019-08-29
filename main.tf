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

resource "aws_internet_gateway" "terraform_example_igw" {
  vpc_id = aws_vpc.terraform_example_vpc.id

  tags = {
    Name      = "terraform-sandbox-igw"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "terraform_public" {
  vpc_id = aws_vpc.terraform_example_vpc.id

  tags = {
    Name      = "terraform-public"
    ManagedBy = "Terraform"
  }
}

// 先ほど作成したルートテーブルに対してレコードを挿入する
resource "aws_route" "public" {
  route_table_id         = aws_route_table.terraform_public.id
  gateway_id             = aws_internet_gateway.terraform_example_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// サブネットにルートテーブルを関連づけする
resource "aws_route_table_association" "public_0" {
  route_table_id = aws_route_table.terraform_public.id
  subnet_id      = aws_subnet.public_0.id
}


module "ec2_security_group" {
  source      = "./modules/security_group"
  name        = "ec2_security_group"
  vpc_id      = aws_vpc.terraform_example_vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_eip" "ec2_instance" {
  vpc = true
  instance = aws_instance.example_0.id

  tags = {
    Name      = "ec2_instance"
    ManagedBy = "Terraform"
  }
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

resource "aws_instance" "example_0" {
  ami           = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_0.id

  // セキュリティグループはsecurity_groupsではなくvpc_security_group_idsで設定すること
  // さもないとセキュリティグループの設定を追加した時にインスタンス削除→再構築されてしまう!
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]

  user_data = <<EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd.service
EOF
}


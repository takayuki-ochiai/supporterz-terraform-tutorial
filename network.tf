resource "aws_vpc" "terraform_sandbox" {
  cidr_block = "10.0.0.0/16"

  // AWS の DNS サーバによる名前解決を有効にする
  enable_dns_support = true

  // trueにするとこのVPC内部のリソースにパブリックDNSホスト名が自動で割り当てられる
  enable_dns_hostnames = true

  tags = {
    Name      = "terraform-sandbox"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_0" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.terraform_sandbox.id

  // このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てる
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name      = "sandbox_public_0"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_1" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.terraform_sandbox.id

  // このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てる
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name      = "sandbox_public_1"
    ManagedBy = "Terraform"
  }
}

resource "aws_internet_gateway" "terraform_sandbox_igw" {
  vpc_id = aws_vpc.terraform_sandbox.id

  tags = {
    Name      = "terraform_sandbox_igw"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terraform_sandbox.id

  tags = {
    Name      = "sandbox_public"
    ManagedBy = "Terraform"
  }
}

// 先ほど作成したルートテーブルに対してレコードを挿入する
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.terraform_sandbox_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

// サブネットにルートテーブルを関連づけする
resource "aws_route_table_association" "public_0" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_0.id
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
}

// ここからプライベートネットワークの設定
resource "aws_subnet" "private_0" {
  cidr_block        = "10.0.65.0/24"
  vpc_id            = aws_vpc.terraform_sandbox.id
  availability_zone = "ap-northeast-1a"

  // このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てない
  map_public_ip_on_launch = false

  tags = {
    Name      = "sandbox_private_0"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.terraform_sandbox.id

  tags = {
    Name      = "sandbox_private_0"
    ManagedBy = "Terraform"
  }
}


resource "aws_route_table_association" "private_0" {
  route_table_id = aws_route_table.private_0.id
  subnet_id      = aws_subnet.private_0.id
}


// NATゲートウェイの設定
// NATゲートウェイにはElastic IPが必要なためEIPを先に作る
// NATゲートウェイが所属するアベイラビリティーゾーンで障害が発生すると片方のアベイラビリティーゾーンでも障害が起きるので、
// NATゲートウェイをアベイラビリティーゾーンごとに作る
resource "aws_eip" "nat_gateway_0" {
  vpc        = true
  depends_on = ["aws_internet_gateway.terraform_sandbox_igw"]

  tags = {
    Name      = "sandbox_nat_gateway_0"
    ManagedBy = "Terraform"
  }
}

resource "aws_nat_gateway" "terraform_sandbox_nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id

  // パブリックサブネットを指定すること
  subnet_id  = aws_subnet.public_0.id
  depends_on = ["aws_internet_gateway.terraform_sandbox_igw"]

  tags = {
    Name      = "sandbox_nat_gateway_0"
    ManagedBy = "Terraform"
  }
}


resource "aws_route" "private_0" {
  route_table_id = aws_route_table.private_0.id

  // gateway_idではなくnat_gateway_idになっていることに注意！
  nat_gateway_id         = aws_nat_gateway.terraform_sandbox_nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}


//module "sandbox_security_group" {
//  source      = "./modules/security_group"
//  name        = "sandbox_security_group"
//  vpc_id      = aws_vpc.terraform_sandbox.id
//  port        = 80
//  cidr_blocks = ["0.0.0.0/0"]
//}

variable "name" {}
variable "vpc_id" {}
variable "port" {}

variable "cidr_blocks" {
  type = "list"
}

// セキュリティグループの設定
resource "aws_security_group" "default" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = {
    Name      = var.name
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group_rule" "ingress_rule" {
  // インバウンドルールの追加
  type = "ingress"

  // ポート範囲を指定
  from_port = var.port
  to_port   = var.port

  // プロトコルの指定
  protocol          = "tcp"
  security_group_id = aws_security_group.default.id

  // 許可するトラフィックのIP範囲をCIDRで指定
  cidr_blocks = var.cidr_blocks
}

// 全てのアウトバウンドトラフィックを許可する
resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.default.id
  cidr_blocks       = ["0.0.0.0/0"]
}

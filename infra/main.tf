terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.regiao_aws
}

resource "aws_launch_template" "maquina" {
  image_id      = "ami-08c40ec9ead489470"
  instance_type = var.instancia
  key_name = var.chave
  tags = {
    Name = var.ambiente
  }
  security_group_names = [ var.grupoDeSeguranca ]
  user_data = var.producao ? filebase64("ansible.sh") : "" #if(?) var.producao = true ele executa o filebase se var.producao = false ele nao executa nada ""
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub") 
}


resource "aws_autoscaling_group" "grupo" {
  availability_zones = [ "${var.regiao_aws}a", "${var.regiao_aws}b" ]
  name = var.nomeGrupo
  max_size = var.maximo
  min_size = var.minimo
  desired_capacity = var.instancias-desejadas
  target_group_arns = var.producao ? [ aws_lb_target_group.alvoLoadBalancer[0].arn ] : [] #if(?) var.producao = true ele cria o load balan cerse var.producao = false ele nao executa nada []
  # como estamos usando o count devemos explicitar [0] (o primeiro loudbalancer que estamos criando) em todos os recursos referentes ao load balancer
  # menssagem de erro: For example, to correlate with indices of a referring resource, use: aws_lb_target_group.alvoLoadBalancer[count.index]
  launch_template {
    id = aws_launch_template.maquina.id
    version = "$Latest"
  }
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
  tags = {
    Name = "default subnet_1-a"
  }
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
  tags = {
    Name = "default subnet_1-b"
  } 
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets = [ aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id ]
  count = var.producao ? 1 : 0 #se var.prodcao =true ele cria 1 lb se falso ele cria 0
}

resource "aws_default_vpc" "vpc" {
  tags = {
    Name = "Default VPC-1"
  }
}

resource "aws_lb_target_group" "alvoLoadBalancer" {
  name = "alvoLoadBalancer"
  port = "8000"
  protocol = "HTTP"
  vpc_id = aws_default_vpc.vpc.id
  count = var.producao ? 1 : 0 
}

resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer[0].arn
  }
  count = var.producao ? 1 : 0 
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name = "terraform-escala"
  depends_on = [ aws_autoscaling_group.grupo ] # para a cria????o desse recurso temos que esperar a cria????o do aws_autoscaling_group.grupo
  autoscaling_group_name = var.nomeGrupo
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  
  
    target_value = 50.0
  }
  count = var.producao ? 1 : 0 
}

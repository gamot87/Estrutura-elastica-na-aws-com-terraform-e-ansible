# Estrutura-elastica-na-aws-com-terraform-e-ansible

Criando uma estrutura elástica com terraform e ansible na AWS executando uma api django. Dou os devidos crédidos ao senhor Guilherme que forneceu o codigo para a aplicação em seu repositório https://github.com/guilhermeonrails/clientes-leo-api.git.

Esse Projeto tem como objetivo subir instândias ami's(ubuntu server) com uma api django em uma estrutura elástica resiliente a falhas e a grandes cargas de acessos, subindo ou derrubando instancias ec2 de acordo com o nivel de cpu utilizado.

Caracteristicas do código:

Cria-se duas subnets default para acolher as máquinas que serão criadas pelo autoscaling.
Cria-se uma vpc default onde toda estrutura será alocada.
Cria-se um Grupo de segurança com acesso livre den entrada e de saída para todos os protocolos e ip's.
Cria-se um loadbalancer e o integra as duas subnets criadas
Cria-se um loadbalancer target group na vpc em questão com suas devidas cofigurações de portas e protocolo (verificar porta da aplicação).
Cria-se o recurso aws_lb_listener (entrada do load balancer) do tipo foward (passa para frente, no caso o lb_target_group)
Cria-se Um auto scaling group com as configurações de ami, número de máquinas minimas,maximas e desejadas.
Adicionamos os códigos criados no arquivo ansible.sh no aws_launch_template no parametro user_data , onde eles serão executados na primeira vez que a máquina entrar em funcionamento, o mesmo instala as dependências , aplicação e coloca em funcionamento a api-django.

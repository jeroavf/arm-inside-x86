### Build de imagens ARM em linux x86 
- Baseado e adaptado do tutorial existente em https://ownyourbits.com/2018/06/27/running-and-building-arm-docker-containers-in-x86/ . Thanks nachoparker (nacho@ownyourbits.com)

#### Instalando o qemu no linux x86
- Assume-se o docker pré instalado e o cluster kubernetes em funcionamento e baseado na distribuição k3s com containerd 

$ sudo apt-get install qemu-user-static  qemu-user -y

#### Teste 
- A magica é realizada pela copia do qemu para dentro do container 

$ docker run -v /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static --rm -ti arm32v7/debian:stretch-slim

#### Teste com criação de container nginx 
- Para fazer o build é necessário ter o qemu-arm-static no mesmo diretorio onde será feito o build da imagem 

$ cp /usr/bin/qemu-arm-static .

$ docker build  -t nginx-armhf:testing .

#### Teste local da imagem no x86 

$ docker run --rm -ti -d -p 80:80 nginx-armhf:testing

$ docker ps 

$ firefox localhost

#### Customizando para colocar em produção no ARM 
- Depois de buildar e verificar se está funcionando, crie novo Dockerfile a partir da primeira imagem criada , que remove o qemu-arm-static e deixa pronto para executar no ARM :

Dockerfile.arm:

FROM nginx-armhf:testing

RUN rm /usr/bin/qemu-arm-static

$ docker build -t nginx-armhf:production -f Dockerfile.arm .


#### Salva a imagem construida no servidor linux x86 local
$ docker save nginx-armhf:production > nginx-armhf-production.tar

#### Transporta para o cluster ARM k3s remoto 
$ scp nginx-armhf-production.tar user@remote-arm-server:/tmp 


#### Remove imagem anterior caso exista no cache do containerd 
$ ssh user@remote-arm-server 'sudo /usr/local/bin/k3s crictl rmi nginx-armhf:production'

#### Importa a imagem para o cache remoto 

$ ssh user@remote-arm-server 'sudo /usr/local/bin/k3s ctr images import /tmp/nginx-armhf-production.tar'

#### Verifica se está no cache remoto 
$ ssh user@remote-arm-server 'sudo /usr/local/bin/k3s crictl images | grep nginx-armhf:production'

#### Apos é só colocar em uso em deployments para o kubernetes como no exemplo do arquivo deste repositorio deployment.yaml 

- O comando pode ser executado no proprio servidor ARM ou na maquina local do usuario desde que tenha o kubectl instalado e possua o arquivo de configuração com as credenciais do cluster k3s

$ kubectl apply -f deployment.yaml 

# OpenVPN for Docker

[![Build Status](https://travis-ci.org/kylemanna/docker-openvpn.svg)](https://travis-ci.org/kylemanna/docker-openvpn)
[![Docker Stars](https://img.shields.io/docker/stars/kylemanna/openvpn.svg)](https://hub.docker.com/r/kylemanna/openvpn/)
[![Docker Pulls](https://img.shields.io/docker/pulls/kylemanna/openvpn.svg)](https://hub.docker.com/r/kylemanna/openvpn/)
[![ImageLayers](https://images.microbadger.com/badges/image/kylemanna/openvpn.svg)](https://microbadger.com/#/images/kylemanna/openvpn)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fkylemanna%2Fdocker-openvpn.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fkylemanna%2Fdocker-openvpn?ref=badge_shield)


OpenVPN server in a Docker container complete with an EasyRSA PKI CA.



# Установка
Перед установкой залить на VPS директории [bin](bin), [otp](otp), [my_scripts](my_scripts) и [Dockerfile](Dockerfile). Я это делаю через VSCode-плагин [SFTP](https://marketplace.visualstudio.com/items?itemName=Natizyskunk.sftp)

Переменная OVPN_DATA дальше везде используется. Ее всегда сначала вбиваем.
```bash
OVPN_DATA="ovpn-data"

# Включить FORWARD в системе
sudo iptables -P FORWARD ACCEPT
```



# VOLUME create
```bash
sudo docker volume ls
sudo docker volume create --name $OVPN_DATA
# sudo docker volume rm $OVPN_DATA

sudo ls -la /var/lib/docker/volumes/$OVPN_DATA
```



# IMAGE build
```bash
cd docker-openvpn

sudo docker images
sudo docker build --network host -t kylemanna/openvpn .
```



# Generate keys and cfg-files
```bash
sudo ls -la /var/lib/docker/volumes/$OVPN_DATA/_data/
# sudo rm /var/lib/docker/volumes/$OVPN_DATA/_data/openvpn.conf
# sudo rm /var/lib/docker/volumes/$OVPN_DATA/_data/ovpn_env.sh

sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig \
    -u tcp://5.187.4.237:443 \
    -s 192.168.201.0/28 \
    -r 192.168.201.0/28 \
    -C AES-256-CBC \
    -a SHA1 \
    -c \
    -e "script-security 2" \
    -e "client-connect /etc/openvpn/client_connect.sh" \
    -e "client-disconnect /etc/openvpn/client_disconnect.sh" \
    -e "topology subnet"

sudo vi /var/lib/docker/volumes/$OVPN_DATA/_data/openvpn.conf
# dev tap0            # это ключ (-t) (стандартный L3 = tun0)
# client-to-client    # это ключ (-c)

sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
# Enter New CA Key Passphrase: > минимум 6 символов
```



# my_scripts
```bash
# Поправить адрес почтовой рассылки
sudo cp my_scripts/* /var/lib/docker/volumes/$OVPN_DATA/_data/
sudo chmod +x /var/lib/docker/volumes/$OVPN_DATA/_data/client_connect.sh
sudo chmod +x /var/lib/docker/volumes/$OVPN_DATA/_data/client_disconnect.sh
# Вписпать пароль почты
sudo vi /var/lib/docker/volumes/$OVPN_DATA/_data/msmtp.conf
```



# start
```bash
sudo vi /var/lib/docker/volumes/$OVPN_DATA/_data/openvpn.conf
# удалить
comp-lzo
# добваить
data-ciphers-fallback AES-256-CBC

sudo docker run \
    --name ovpn \
    --net=host \
    -v $OVPN_DATA:/etc/openvpn \
    -d \
    -p 443:1194/tcp \
    --cap-add=NET_ADMIN \
    kylemanna/openvpn

sudo docker run \
    --name ovpn443 \
    -v $OVPN_DATA:/etc/openvpn \
    -d \
    -p 443:1194/tcp \
    --privileged \
    kylemanna/openvpn ovpn_run

sudo docker ps -a
```



# OVPN-file generate
```bash
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full frankfurt_ars nopass
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full frankfurt_ket nopass
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full frankfurt_alex nopass
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full frankfurt_tema nopass
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full frankfurt_lexa nopass

sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient frankfurt_ars > ~/docker-openvpn/frankfurt_ars.ovpn
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient frankfurt_ket > ~/docker-openvpn/frankfurt_ket.ovpn
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient frankfurt_alex > ~/docker-openvpn/frankfurt_alex.ovpn
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient frankfurt_tema > ~/docker-openvpn/frankfurt_tema.ovpn
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient frankfurt_lexa > ~/docker-openvpn/frankfurt_lexa.ovpn

# добавить в конфиг клиента (проверить tcp и порт)
echo "
data-ciphers-fallback AES-256-CBC
auth-nocache
" >> ~/docker-openvpn/frankfurt_ars.ovpn

echo "
data-ciphers-fallback AES-256-CBC
auth-nocache
" >> ~/docker-openvpn/frankfurt_ket.ovpn 

echo "
data-ciphers-fallback AES-256-CBC
auth-nocache
" >> ~/docker-openvpn/frankfurt_alex.ovpn 

echo "
data-ciphers-fallback AES-256-CBC
auth-nocache
" >> ~/docker-openvpn/frankfurt_tema.ovpn 

echo "
data-ciphers-fallback AES-256-CBC
auth-nocache
" >> ~/docker-openvpn/frankfurt_lexa.ovpn 
```



# assign static clients IP
```bash
sudo -i
OVPN_DATA="ovpn-data"

ls -la /var/lib/docker/volumes/$OVPN_DATA/_data/pki/issued/
ls -la /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/

echo "ifconfig-push 192.168.201.2 255.255.255.240" > /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/frankfurt_ars
echo "ifconfig-push 192.168.201.3 255.255.255.240" > /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/frankfurt_ket
echo "ifconfig-push 192.168.201.4 255.255.255.240" > /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/frankfurt_alex
echo "ifconfig-push 192.168.201.5 255.255.255.240" > /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/frankfurt_tema
echo "ifconfig-push 192.168.201.6 255.255.255.240" > /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/frankfurt_lexa
```



# Pluggable Transports
```bash
# https://go.dev/doc/install
	sudo -i
	cd /usr/src
	wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz
	rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
# Ctrl+D
export PATH=$PATH:/usr/local/go/bin
go version



# https://www.pluggabletransports.info/implement/openvpn/
# https://www.pluggabletransports.info/implement/shapeshifter/

cd ~
git clone https://github.com/OperatorFoundation/shapeshifter-dispatcher
cd ~/shapeshifter-dispatcher
go build



cd ~/shapeshifter-dispatcher
./shapeshifter-dispatcher -generateConfig -transport shadow -serverIP 5.187.4.237:8443

Server
./shapeshifter-dispatcher -server -transparent -state state -transports shadow -target 5.187.4.237:1194 -bindaddr shadow-5.187.4.237:8443 -optionsFile ShadowServerConfig.json -logLevel DEBUG -enableLogging

Client
./shapeshifter-dispatcher -client -transparent -state state -transports shadow -proxylistenaddr 127.0.0.1:1194 -optionsFile ShadowClientConfig.json -logLevel DEBUG -enableLogging

```

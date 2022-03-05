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
    -u udp://65.108.82.45:1194 \
    -s 192.168.201.0/28 \
    -r 192.168.201.0/28 \
    -C AES-256-CBC \
    -a SHA1 \
    -z \
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
sudo docker run \
    --name ovpn \
    --net=host \
    -v $OVPN_DATA:/etc/openvpn \
    -d \
    --cap-add=NET_ADMIN \
    kylemanna/openvpn

sudo docker run \
    --name ovpn443 \
    -v $OVPN_DATA:/etc/openvpn \
    -d \
    -p 443:1194/tcp \
    --privileged \
    kylemanna/openvpn ovpn_run --proto tcp

sudo docker ps -a
```



# OVPN-file generate
```bash
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full helsinki_ars nopass
sudo docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient helsinki_ars > ~/docker-openvpn/helsinki_ars.ovpn
```



# assign static clients IP
```bash
sudo -i
OVPN_DATA="ovpn-data"

ls -la /var/lib/docker/volumes/$OVPN_DATA/_data/pki/issued/
ls -la /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/

echo "ifconfig-push 192.168.201.2 255.255.255.240" > /var/lib/docker/volumes/$OVPN_DATA/_data/ccd/helsinki_ars
```
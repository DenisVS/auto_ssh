#!/bin/sh

#TUNNEL_IP - IP сервера туннеля в местной локальной сети (на время наладки)
#TUNNEL_DOMAIN - домен сервера туннеля
#TUNNEL_PORT - порт SSH демона на сервере туннеля
#TUNNEL_USER - пользователь туннеля на сервере
#TUNNEL_BIND_PORT - SSH порт, организуемый на сервере туннеля для форвардинга соединений
#TARGET_HOST - хост, на который форвардится SSH соединение (обычно, 127.0.0.1 для управления инициирующим туннель компьютером)
#TARGET_PORT - порт, на который форвардится SSH соединение

#TUNNEL_IP=192.168.1.60
TUNNEL_DOMAIN=example.com
TUNNEL_PORT=20022
TUNNEL_USER=sshtunnel
OPTIONS_STRING="-R 192.168.1.60:32750:127.0.0.1:1944 -R 192.168.1.60:4242:192.168.1.20:80"

# Получаем статус соединения (ssh)
#CONNECT=`/usr/bin/sockstat | grep 8.8.8.8:20022 | awk '{print $2}'`
if [ "${TUNNEL_DOMAIN}" != "" ]; then
    # Получаем IP из домена
    #DOMAIN_IP=`/usr/bin/drill example.com | grep ^example.com | grep '[[:blank:]]A[[:blank:]]' | awk '{print $5}'`
    DOMAIN_IP=`/usr/bin/drill ${TUNNEL_DOMAIN} | grep ^${TUNNEL_DOMAIN} | grep '[[:blank:]]A[[:blank:]]' | awk '{print $5}'`
    echo DOMAIN_IP=${DOMAIN_IP}    
    CONNECT_DOMAIN=`/usr/bin/sockstat | grep ${DOMAIN_IP}:${TUNNEL_PORT} | awk '{print $2}'`
    echo CONNECT_DOMAIN=${CONNECT_DOMAIN}
fi
if [ "${TUNNEL_IP}" != "" ]; then
    CONNECT_IP=`/usr/bin/sockstat | grep ${TUNNEL_IP}:${TUNNEL_PORT} | awk '{print $2}'`
    echo CONNECT_IP=${CONNECT_IP}
fi

if [ "${CONNECT_IP}" = "ssh" -o "${CONNECT_DOMAIN}" = "ssh" ]; then
    echo "Tunnel online."
    exit 1
else
    echo "Tunnel ofline."
    echo "Now up tunnel."
    if [ "${TUNNEL_DOMAIN}" != "" ]; then
        ssh -f -N ${OPTIONS_STRING} ${TUNNEL_USER}@${TUNNEL_DOMAIN} -p${TUNNEL_PORT}
    fi        
    if [ "${TUNNEL_IP}" != "" ]; then
        ssh -f -N ${OPTIONS_STRING} ${TUNNEL_USER}@${TUNNEL_IP} -p${TUNNEL_PORT}
    fi
    exit 1
fi

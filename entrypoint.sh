#!/bin/sh


## READ DEFAULT VALUES _________________________________________
# Extract the desired variables using jq
name=$(jq -r '.name' ${TMP_XRAY}default_xray.json )
email=$(jq -r '.email' ${TMP_XRAY}default_xray.json )
vless_port=$(jq -r '.VLESS_PORT' ${TMP_XRAY}default_xray.json )
sni=$(jq -r '.sni' ${TMP_XRAY}default_xray.json )
path_vless_nginx=$(jq -r '.path_vless_nginx' ${TMP_XRAY}default_xray.json )


# NGIX Config __________________________________________________

sed -i "s#VLESS_PORT#$vless_port#g" /etc/nginx/nginx.conf
# xray ___________________________________________________________

json=$(cat < ${TMP_XRAY}config.json)

keys=$(xray x25519)

pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ipv4.wtfismyip.com/text)

if [ -z "${serverIp}" ]; then
    serverIp="127.0.0.1"
fi
uuid=$(xray uuid)
shortId=$(openssl rand -hex 8)


newJson=$(echo "$json" | jq \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    --arg port "$vless_port" \
    --arg sni "$sni" \
    --arg path "$path" \
    --arg email "$email" \
     --arg pub "$pub" \
    '.inbounds[0].port= ($port|tonumber) |
     .inbounds[0].settings.clients[0].email = $email |
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.dest = $sni + ":443" |
     .inbounds[0].streamSettings.realitySettings.serverNames = ["'$sni'", "www.'$sni'"] |
     .inbounds[0].streamSettings.realitySettings.privateKey = $pk |
     .inbounds[0].streamSettings.realitySettings.publicKey = $pub |
     .inbounds[0].streamSettings.realitySettings.shortIds = ["'$shortId'"]')



echo "$newJson" |  tee ${CNF_XRAY}config.json 

#vless://090b54a4-1b11-4839-8ffe-f7e4a303d70e@91.107.192.176:5333?encryption=none&flow=xtls-rprx-vision&security=reality&sni=yahoo.com&fp=chrome&pbk=bN58-hq-xvImq10TQNT2pgr4oJnao_zkYdF5u3H2y1E&sid=c64e7fa8&type=tcp&headerType=none#farzin_adsl1-farzin_adsl1


url="vless://$uuid@$serverIp:$vless_port?type=tcp&security=reality&encryption=none&flow=xtls-rprx-vision&pbk=$pub&fp=chrome&sni=$sni&sid=$shortId&headerType=none#$name"
echo "URL : >>   $url"
echo "$url" >> /root/testurl.url
qrencode -s 120 -t ANSIUTF8 "$url"
qrencode -s 50 -o qr.png "$url"
#(cd /usr/local/bin; ./xray)
#/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
exit 0
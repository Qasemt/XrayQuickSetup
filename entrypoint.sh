#!/bin/sh



VMESS_WSPATH=${VMESS_WSPATH:-'/vmess'}
VLESS_WSPATH=${VLESS_WSPATH:-'/vless'}
PUBKEY_VL=${PUBKEY_VL:-"mzevpYbS8kXengBY5p7tt56QE4tS3lwlwRemmkcQeyc"}
PRVKEY_VL=${PRVKEY_VL:-"0H3OJEYEu6XW7woqy7cKh2vzg6YHkbF_xSDTHKyrsn4"}
SHORTID_VL=${SHORTID_VL:-"71ec2cd1"}
SNI_VL=${SNI_VL:-"yahoo.com"}
SNI_FULL=${SNI_FULL:-"[\"yahoo.com\", \"www.yahoo.com\"]"}
#NGINX_PORT=${NGINX_PORT:-""}
URL="www.server_name.net"-8080.csb.app
if [ -z "${URL}" ]; then
    URL="127.0.0.1"
fi
sed -i "s#UUID#$UUID#g;s#PUBKEY_VL#$PUBKEY_VL#g;s#PRVKEY_VL#$PRVKEY_VL#g;s#SHORTID_VL#$SHORTID_VL#g;s#SNI_VL#$SNI_VL#g;s#SNI_FULL#$SNI_FULL#g;s#VMESS_WSPATH#$VMESS_WSPATH#g;s#VLESS_WSPATH#$VLESS_WSPATH#g" /usr/local/etc/xray/config.json


#sed -i "s#VMESS_WSPATH#$VMESS_WSPATH#g;s#VLESS_WSPATH#$VLESS_WSPATH#g" /etc/nginx/nginx.conf

vmlink=vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"vmess_usr\",\"add\":\"$URL\",\"port\":\"443\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$URL\",\"path\":\"$VMESS_WSPATH\",\"tls\":\"tls\"}" | base64 -w 0)

vllink="vless://$UUID@$URL:443?type=tcp&security=reality&encryption=none&flow=xtls-rprx-vision&pbk=$PUBKEY_VL&fp=chrome&sni=$SNI_VL&sid=$SNI_VL&headerType=none&path="$VLESS_WSPATH"#Vless_Reality1"

qrencode -o /usr/share/nginx/html/M${UUID}vm.png $vmlink
qrencode -o /usr/share/nginx/html/L${UUID}vl.png $vllink

cat > /usr/share/nginx/html/$UUID.html<<-EOF
<html>
<head>
<title>Codesandbox</title>
<style type="text/css">
body {
      font-family: Geneva, Arial, Helvetica, san-serif;
    }
div {
      margin: 0 auto;
      text-align: left;
      white-space: pre-wrap;
      word-break: break-all;
      max-width: 80%;
      margin-bottom: 10px;
}
</style>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<div><font color="#009900"><b>VMESS协议链接：</b></font></div>
<div>$vmlink</div>
<div><font color="#009900"><b>VMESS协议二维码：</b></font></div>
<div><img src="/M${UUID}vm.png"></div>
<div><font color="#009900"><b>VLESS协议链接：</b></font></div>
<div>$vllink</div>
<div><font color="#009900"><b>VLESS协议二维码：</b></font></div>
<div><img src="/L${UUID}vl.png"></div>
</body>
</html>
EOF
echo https://$URL/$UUID.html > ${CNF_XRAY}/info
exit 0
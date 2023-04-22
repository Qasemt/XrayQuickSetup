FROM nginx:mainline-alpine-slim

LABEL maintainer="qasemt@gmail.net"
LABEL version="0.1"
LABEL description="docker image for xray reality Qasemt@gmail.com"

EXPOSE 80
USER root

ENV TMP_XRAY /usr/local/tmp_xray/
ENV CNF_XRAY /usr/local/etc/xray/
ENV VLESS_WSPATH /vless
RUN mkdir -p $TMP_XRAY && \
    mkdir -p $CNF_XRAY

RUN apk update && \
    apk upgrade && \
    apk add --no-cache supervisor  wget curl openssl libqrencode  jq unzip tzdata bash nano 



COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#COPY nginx.conf /etc/nginx/nginx.conf
COPY config.json $TMP_XRAY 
COPY default_xray.json $TMP_XRAY 
COPY entrypoint.sh $TMP_XRAY 

# Install Xray-core
RUN curl -L -H "Cache-Control: no-cache" -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v1.8.1/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    rm /tmp/xray.zip && \
    chmod +x /usr/local/bin/xray
#end 

## INSTLL
##apk del wget unzip  && \
RUN chmod a+x "${TMP_XRAY}entrypoint.sh" && \
    rm -rf /tmp/xray.zip && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

WORKDIR $TMP_XRAY
RUN sh  entrypoint.sh

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

#ENTRYPOINT ["tail", "-f", "/dev/null"]

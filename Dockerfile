# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM alpine:3.18

ARG SINGBOX_VERSION="1.11.1"
ARG MOSDNS_VERSION="v5.3.3"
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache ca-certificates supervisor

# 根据架构生成平台标识
RUN case "${TARGETARCH}-${TARGETVARIANT}" in \
    "amd64-")      SINGBOX_ARCH=amd64; MOSDNS_ARCH=amd64 ;; \
    "arm64-")      SINGBOX_ARCH=arm64; MOSDNS_ARCH=arm64 ;; \
    "arm-v7")      SINGBOX_ARCH=armv7; MOSDNS_ARCH=arm-7 ;; \
    *) echo "Unsupported platform: ${TARGETARCH}-${TARGETVARIANT}"; exit 1 ;; \
    esac && \
    echo "Target arch: ${SINGBOX_ARCH}" > /arch.txt

# 下载 sing-box
RUN wget -O /opt/sing-box.tar.gz \
    "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/sing-box-${SINGBOX_VERSION}-linux-${SINGBOX_ARCH}.tar.gz" && \
    mkdir -p /opt/sing-box && \
    tar -xzf /opt/sing-box.tar.gz -C /opt/sing-box --strip-components=1 && \
    rm -rf /opt/sing-box.tar.gz

# 下载 mosdns
RUN wget -O /opt/mosdns.zip \
    "https://github.com/IrineSistiana/mosdns/releases/download/${MOSDNS_VERSION}/mosdns-linux-${MOSDNS_ARCH}.zip" && \
    mkdir -p /opt/mosdns && \
    unzip /opt/mosdns.zip -d /opt/mosdns && \
    rm /opt/mosdns.zip

# 复制配置文件
COPY config/sing-box.json /opt/sing-box/config.json
COPY config/mosdns.yaml /opt/mosdns/config.yaml
COPY config/plugins/* /opt/mosdns
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/entrypoint.sh /entrypoint.sh

# 创建运行目录
RUN mkdir -p /var/log/sing-box && \
    mkdir -p /var/log/mosdns && \
    chmod +x /opt/sing-box/sing-box && \
    chmod +x /opt/mosdns/mosdns && \
    chmod +x /entrypoint.sh

EXPOSE 53/udp 53/tcp 5354/udp 5354/tcp 80 9090
ENTRYPOINT ["/entrypoint.sh"]

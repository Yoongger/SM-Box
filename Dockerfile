# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM alpine:3.18

ARG SING_BOX_VERSION="1.11.1"
ARG MOSDNS_VERSION="v5.3.3"
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache ca-certificates supervisor

# 安装sing-box
RUN case "${TARGETARCH}" in \
    "amd64") SING_ARCH="amd64" ;; \
    "arm64") SING_ARCH="arm64" ;; \
    "arm") \
        case "${TARGETVARIANT}" in \
            "v7") SING_ARCH="armv7" ;; \
            *) echo "Unsupported ARM variant: ${TARGETVARIANT}"; exit 1 ;; \
        esac ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    wget -O sing-box.tar.gz \
        "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-${SING_ARCH}.tar.gz" && \
    tar -xzf sing-box.tar.gz && \
    mv sing-box-*/sing-box /usr/local/bin/ && \
    rm -rf sing-box.tar.gz sing-box-*

# 安装mosdns
RUN case "${TARGETARCH}" in \
    "amd64") MOSDNS_ARCH="amd64" ;; \
    "arm64") MOSDNS_ARCH="arm64" ;; \
    "arm") \
        case "${TARGETVARIANT}" in \
            "v7") MOSDNS_ARCH="arm-7" ;; \
            *) echo "Unsupported ARM variant: ${TARGETVARIANT}"; exit 1 ;; \
        esac ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    wget -O mosdns.zip \
        "https://github.com/IrineSistiana/mosdns/releases/download/${MOSDNS_VERSION}/mosdns-linux-${MOSDNS_ARCH}.zip" && \
    unzip mosdns.zip && \
    mv mosdns /usr/local/bin/ && \
    rm mosdns.zip

# 复制配置文件
COPY config/sing-box.json /etc/sing-box/config.json
COPY config/mosdns.yaml /etc/mosdns.yaml
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 创建运行目录
RUN mkdir -p /var/log/sing-box && \
    mkdir -p /var/log/mosdns && \
    chmod +x /usr/local/bin/sing-box && \
    chmod +x /usr/local/bin/mosdns

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM alpine:3.18

ARG SING_BOX_VERSION="1.11.1"
ARG MOSDNS_VERSION="v5.3.3"
ARG UIF_VERSION="v25.01.10"
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache ca-certificates supervisor


# 安装UIF
# RUN case "${TARGETARCH}" in \
#     "amd64") UIF_ARCH="amd64" ;; \
#     "arm64") UIF_ARCH="arm64" ;; \
#     "arm") \
#         case "${TARGETVARIANT}" in \
#             "v7") UIF_ARCH="armv7" ;; \
#             *) echo "Unsupported ARM variant: ${TARGETVARIANT}"; exit 1 ;; \
#         esac ;; \
#     *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
#     esac && \
#     wget -O /uif.tar.gz \
#         "https://github.com/UIforFreedom/UIF/releases/download/${UIF_VERSION}/uif-linux-${UIF_ARCH}.tar.gz" && \
#     mkdir -p /smbox && \
#     tar -xzf /uif.tar.gz -C /smbox --strip-components=1 && \
#     rm /uif.tar.gz

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
    wget -O /sing-box.tar.gz \
        "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-${SING_ARCH}.tar.gz" && \
    mkdir -p /smbox/sing-box && \
    tar -xzf /sing-box.tar.gz -C /smbox/sing-box --strip-components=1 && \
    rm -rf /sing-box.tar.gz

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
    wget -O /mosdns.zip \
        "https://github.com/IrineSistiana/mosdns/releases/download/${MOSDNS_VERSION}/mosdns-linux-${MOSDNS_ARCH}.zip" && \
    mkdir -p /smbox/mosdns && \
    unzip /mosdns.zip -d /smbox/mosdns && \
    rm /mosdns.zip

# 复制配置文件
COPY config/sing-box /smbox/sing-box
COPY config/mosdns /smbox/mosdns
# COPY config/uif /smbox
COPY scripts/supervisord.conf /etc/supervisord.conf
COPY scripts/entrypoint.sh /entrypoint.sh

# 创建运行目录
RUN mkdir -p /var/log/sing-box && \
    mkdir -p /var/log/mosdns && \
    mkdir -p /var/log/uif && \
    chmod +x /smbox/sing-box/sing-box && \
    chmod +x /smbox/mosdns/mosdns && \
    # chmod +x /smbox/uif && \
    chmod +x /entrypoint.sh

EXPOSE 53/udp 53/tcp 8080 5354 9090
#CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
ENTRYPOINT ["/entrypoint.sh"]
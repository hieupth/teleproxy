ARG BASE_IMAGE=debian

FROM ${BASE_IMAGE} as build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
      tini \
      python3 \
      python3-uvloop \
      python3-cryptography \
      python3-socks \
      libcap2-bin \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN setcap cap_net_bind_service=+ep /usr/bin/python
ENTRYPOINT ["tini", "-g", "--"]

FROM build as source
RUN apt install -y git
RUN git clone https://github.com/alexbers/mtprotoproxy /mtproto

FROM build 
USER tgproxy
WORKDIR /home/tgproxy/
COPY --from=source --chown=tgproxy /mtproto/mtprotoproxy.py /mtproto/config.py /home/tgproxy/
CMD ["python3", "mtprotoproxy.py"]
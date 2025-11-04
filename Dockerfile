ARG BASE_IMAGE_REPO=effectiverange/armhf-bookworm-tools-base
ARG BASE_IMAGE_VER=latest

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_VER}

RUN apt update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt update -y && \
    apt install -y gcc wget python3 python3-pip inetutils-ping openssh-client pkg-config dpkg-dev nano git sudo packaging-tools


# Set up start script
COPY --chown=crossbuilder:crossbuilder ./start.sh /home/crossbuilder/start.sh
WORKDIR "/home/crossbuilder"

CMD ["/home/crossbuilder/start.sh"]

ARG BASE_IMAGE_REPO=effectiverange/armhf-bookworm-tools-base
ARG BASE_IMAGE_VER=latest
ARG PACKAGING_TOOLS_VER=latest

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_VER}

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt_update -y && \
    apt_install -y gcc wget python3 python3-pip inetutils-ping openssh-client pkg-config dpkg-dev nano git sudo

RUN . /etc/os-release && \
    if [ "${PACKAGING_TOOLS_VER}" = "latest" ]; then \
        apt_install -y packaging-tools; \
    else \
        wget -O /tmp/packaging-tools.deb \
        "https://github.com/EffectiveRange/packaging-tools/releases/download/${PACKAGING_TOOLS_VER}/${VERSION_CODENAME}_packaging-tools_${PACKAGING_TOOLS_VER}_all.deb" && \
        apt install -y /tmp/packaging-tools.deb && \
        rm /tmp/packaging-tools.deb && \
    fi

# Set up start script
COPY --chown=crossbuilder:crossbuilder ./start.sh /home/crossbuilder/start.sh
WORKDIR "/home/crossbuilder"

CMD ["/home/crossbuilder/start.sh"]

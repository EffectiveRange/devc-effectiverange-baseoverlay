ARG BASE_IMAGE_REPO=effectiverange/armhf-bookworm-tools-base
ARG BASE_IMAGE_VER=latest

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_VER}

ARG PACKAGING_TOOLS_VER=latest
ARG XDRVMAKE_VER=latest
ENV PACKAGING_TOOLS_VER=${PACKAGING_TOOLS_VER}
ENV XDRVMAKE_VER=${XDRVMAKE_VER}

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt_update -y && \
    apt_install -y gcc wget python3 python3-pip inetutils-ping openssh-client pkg-config dpkg-dev nano git sudo jq

RUN . /etc/os-release && \
    if [ "${PACKAGING_TOOLS_VER}" = "latest" ]; then \
        apt_install -y packaging-tools; \
    else \
        wget -O /tmp/packaging-tools.deb \
        "https://github.com/EffectiveRange/packaging-tools/releases/download/${PACKAGING_TOOLS_VER}/${VERSION_CODENAME}_packaging-tools_${PACKAGING_TOOLS_VER#v}-1_all.deb" && \
        apt install -y /tmp/packaging-tools.deb && \
        rm -f /tmp/packaging-tools.deb; \
    fi

# Download xdrvmake wheel from GitHub releases and install it
RUN set -eux; \
    REPO="EffectiveRange/python-xdrvmake"; \
    VER="${XDRVMAKE_VER}"; \
    \
    if [ "$VER" = "latest" ]; then \
      API="https://api.github.com/repos/${REPO}/releases/latest"; \
    else \
      # Accept both "0.3.1" and "v0.3.1"
      case "$VER" in v*) TAG="$VER" ;; *) TAG="v$VER" ;; esac; \
      API="https://api.github.com/repos/${REPO}/releases/tags/${TAG}"; \
    fi; \
    \
    # Pick the wheel asset you want. If you publish multiple wheels, tighten this selector.
    WHEEL_URL="$(curl -fsSL "$API" \
      | jq -r '.assets[] | select(.name | endswith(".whl")) | .browser_download_url' \
      | head -n1)"; \
    test -n "$WHEEL_URL"; \
    \
    pipx install --global "$WHEEL_URL"; \
    rm -f /tmp/xdrvmake.whl

# Set up start script
COPY --chmod=777 --chown=crossbuilder:crossbuilder ./start.sh /home/crossbuilder/start.sh
WORKDIR "/home/crossbuilder"

CMD ["/home/crossbuilder/start.sh"]
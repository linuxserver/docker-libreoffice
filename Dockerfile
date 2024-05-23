FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine320

# set version label
ARG BUILD_DATE
ARG VERSION
ARG LIBREOFFICE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=LibreOffice

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/libreoffice-logo.png && \
  echo "**** install packages ****" && \
  if [ -z ${LIBREOFFICE_VERSION+x} ]; then \
    LIBREOFFICE_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.20/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:libreoffice$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    libreoffice==${LIBREOFFICE_VERSION} \
    openjdk8-jre \
    st \
    thunar \
    tint2 && \
  echo "**** locales ****" && \
  for LOCALE in $(curl -sL https://raw.githubusercontent.com/thelamer/lang-stash/master/langs); do \
    apk add --no-cache libreoffice-lang-$(echo ${LOCALE}| tr '[:upper:]' '[:lower:]') || apk add --no-cache libreoffice-lang-$(echo ${LOCALE}| head -c2); \
  done && \
  echo "**** openbox tweaks ****" && \
  sed -i \
    's/NLMC/NLIMC/g' \
    /etc/xdg/openbox/rc.xml && \
  sed -i \
    '/Icon=/c Icon=xterm-color_48x48' \
    /usr/share/applications/st.desktop && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config

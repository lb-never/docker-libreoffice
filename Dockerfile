FROM lsiobase/rdesktop-web:alpine

# set version label
ARG BUILD_DATE
ARG VERSION
ARG LIBREOFFICE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

COPY front/ /usr/share/fonts/

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    curl && \
  if [ -z ${LIBREOFFICE_VERSION+x} ]; then \
    LIBREOFFICE_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.15/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:libreoffice$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    libreoffice==${LIBREOFFICE_VERSION} \
    openjdk8-jre \
    tint2 && \
  echo "**** openbox tweaks ****" && \
  sed -i \
    's/NLMC/NLIMC/g' \
    /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* &&  fc-cache -fv

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config

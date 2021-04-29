FROM golang:1.16-alpine3.13
ARG ENCORE_VERSION="0.13.4"
RUN \
  apk add --no-cache ca-certificates docker-cli git && \
  \
  wget -O "/etc/apk/keys/sgerrand.rsa.pub" "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
  wget -O "/tmp/glibc.apk" "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk" && \
  apk add "/tmp/glibc.apk" && rm "/tmp/glibc.apk" && \
  \
  adduser -D "encore"
USER encore
RUN \
  mkdir -p "$HOME/.encore" && \
  wget -O "/tmp/encore.tar.gz" "https://d2f391esomvqpi.cloudfront.net/encore-$ENCORE_VERSION-linux_amd64.tar.gz" && \
  tar -C "$HOME/.encore" -xf "/tmp/encore.tar.gz" && \
  rm "/tmp/encore.tar.gz" && \
  \
  mkdir -p "/home/encore/app"
WORKDIR "/home/encore/app"
ENV PATH="/home/encore/.encore/bin:$PATH"
VOLUME /run/docker.sock
VOLUME /home/encore/.git
VOLUME /home/encore/.ssh
VOLUME /home/encore/app
EXPOSE 4060
ENTRYPOINT ["/home/encore/.encore/bin/encore"]


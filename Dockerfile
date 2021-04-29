FROM golang:1.16-alpine3.13 as encore-go
ARG ENCORE_GO_VERSION="1.16"
RUN \
  apk add --no-cache bash gcc git musl-dev openssl && \
  git clone --depth 1 -b "encore$ENCORE_GO_VERSION" "https://github.com/encoredev/go" "src/github.com/encoredev/go" && \
  export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
  cd "src/github.com/encoredev/go/src" && ./make.bash && cd "$OLDPWD"

FROM golang:1.16-alpine3.13 as encore-runtime
ARG ENCORE_RUNTIME_VERSION="0.13.2"
RUN \
  apk add --no-cache git && \
  git clone --depth 1 -b "v$ENCORE_RUNTIME_VERSION" "https://github.com/encoredev/encore.dev" "src/github.com/encoredev/encore.dev"

FROM golang:1.16-alpine3.13 as encore
ARG ENCORE_VERSION="0.13.1"
COPY --from=encore-go /go/src/github.com/encoredev/go /go/src/github.com/encoredev/encore-go
RUN \
  apk add --no-cache git nodejs npm && npm install -g npm && \
  npm config set ignore-scripts false && \
  git clone --depth 1 -b "v$ENCORE_VERSION" "https://github.com/encoredev/encore" "src/github.com/encoredev/encore" && \
  cd "src/github.com/encoredev/encore" && \
  go run "./pkg/make-release/make-release.go" -v="$ENCORE_VERSION" -dst="dist" -goos="linux" -goarch="amd64" -encore-go="../encore-go" && \
  go build -o "./bin/" "./cli/cmd/..." && \
  cd "$OLDPWD"

FROM golang:1.16-alpine3.13
RUN apk add --no-cache docker-cli git
COPY --from=encore-go /go/src/github.com/encoredev/go /home/encore/.encore/encore-go
COPY --from=encore-runtime /go/src/github.com/encoredev/encore.dev /home/encore/.encore/encore-runtime
COPY --from=encore /go/src/github.com/encoredev/encore/bin /home/encore/.encore/bin
RUN \
  adduser -D encore && \
  mkdir -p "/home/encore/app" && \
  chown -R encore:encore "/home/encore"
USER encore
WORKDIR "/home/encore/app"
ENV PATH="$HOME/.encore/bin:$PATH"


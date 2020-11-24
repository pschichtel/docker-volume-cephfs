FROM golang:1.15-alpine as builder
COPY . /go/src/github.com/n0r1skcom/docker-volume-cephfs
WORKDIR /go/src/github.com/n0r1skcom/docker-volume-cephfs
RUN apk add --no-cache --virtual .build-deps \
    gcc libc-dev
RUN go install --ldflags '-extldflags "-static"'

FROM alpine:3.12
RUN mkdir -p /run/docker/plugins /mnt/state /mnt/volumes
COPY --from=builder /go/bin/docker-volume-cephfs .
CMD ["docker-volume-cephfs"]

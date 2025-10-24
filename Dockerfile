ARG ALPINE_VERSION=3.22
ARG GO_VERSION=1.24.9

ARG WAIT_VERSION=2.12.1

ARG GALENE_VERSION=1.0
ARG RELEASE_TAG=1

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS build
WORKDIR /go/src/galene

ARG GALENE_VERSION

RUN apk --no-cache add git \
    && git clone --depth 1 --branch galene-$GALENE_VERSION https://github.com/jech/galene.git ./
RUN CGO_ENABLED=0 go build -ldflags='-s -w'

FROM alpine:${ALPINE_VERSION}
WORKDIR /opt/galene

ARG WAIT_VERSION

ARG GIT_COMMIT="N/A"
ARG GALENE_VERSION
ARG RELEASE_TAG

RUN mkdir groups/

EXPOSE 8443
EXPOSE 1194/tcp
EXPOSE 1194/udp

COPY --from=build /go/src/galene/LICENCE /go/src/galene/galene ./
COPY --from=build /go/src/galene/static/ ./static/

COPY root/ /

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/${WAIT_VERSION}/wait /docker-init.d/01-docker-compose-wait
RUN chmod 0755 /docker-init.d/01-docker-compose-wait

ENTRYPOINT ["/docker-init.sh"]

LABEL maintainer="galene@flexoft.net" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="galene" \
    org.label-schema.description="Docker image for the Galène videoconference server" \
    org.label-schema.url="http://galena.org/" \
    org.label-schema.vcs-url="https://github.com/Guiorgy/galene" \
    org.label-schema.vcs-ref="${GIT_COMMIT}" \
    org.label-schema.vendor="jech" \
    org.label-schema.version="${GALENE_VERSION}-${RELEASE_TAG}"

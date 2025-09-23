ARG TARGETOS
ARG TARGETARCH
ARG VERSION

FROM golang:1.24.5-alpine AS builder
WORKDIR /go/src/app
RUN apk add --no-cache make git
COPY . .

RUN echo "Building for OS: ${TARGETOS} and Architecture: ${TARGETARCH}"
RUN make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH} TELE_TOKEN=$(cat /run/secrets/tele_token) VERSION=${VERSION}
FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot" ]
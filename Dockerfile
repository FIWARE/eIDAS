FROM alpine:latest

# Install OpenSSL
RUN apk update && \
  apk add --no-cache openssl openjdk21-jre envsubst && \
  rm -rf "/var/cache/apk/*"

COPY script/script.sh /openssl-certs/
COPY script/config /config/
COPY script/openssl-client.cnf /openssl-certs/
COPY script/openssl-intermediate.cnf /openssl-certs/
COPY script/openssl.cnf /openssl-certs/

ENV OUTPUT_FOLDER="/out/"
ENV CONFIG_FILE="/config/config"

WORKDIR /openssl-certs

ENTRYPOINT ["sh", "-c", "./script.sh"]
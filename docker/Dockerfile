FROM registry.access.redhat.com/ubi8/ubi

# Install OpenSSL
RUN yum install -y openssl

# Create and set mount volume
WORKDIR /openssl-certs
VOLUME  /openssl-certs

ENTRYPOINT ["sh"]
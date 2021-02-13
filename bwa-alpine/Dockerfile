FROM frolvlad/alpine-glibc:alpine-3.13 AS builder

# Download and install mamba into /usr/bin
ENV MAMBAFORGE_VERSION=4.9.2-5
RUN apk add --update curl && \
    curl -sL https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-pypy3-Linux-x86_64.sh -o /tmp/mambaforge.sh && \
    sh /tmp/mambaforge.sh -bfp /usr && rm -f /tmp/mambaforge.sh

# Use mamba to install remaining tools/dependencies into /usr/local
ENV BWA_VERSION=0.7.17
RUN mamba create -qy -p /usr/local \
        -c bioconda \
        bwa==${BWA_VERSION}

# Deploy the target tools into a base image
FROM frolvlad/alpine-glibc:alpine-3.13
COPY --from=builder /usr/local /usr/local

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.bwa="0.7.17-alpine"

# BUILD_CMD: docker build --pull -t bwa:0.7.17-alpine .

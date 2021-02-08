FROM ubuntu:20.04 AS builder

# Download and install conda into /usr/bin
ENV MINICONDA_VERSION=py37_4.9.2
RUN apt-get update && apt-get install -y curl && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    sh /tmp/miniconda.sh -bfp /usr

# Use conda to install remaining tools/dependencies into /usr/local
ENV BWA_VERSION=0.7.17
RUN conda create -qy -p /usr/local \
        -c bioconda \
        bwa==${BWA_VERSION}

# Deploy the target tools into a base image
FROM ubuntu:20.04
COPY --from=builder /usr/local /usr/local

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.bwa="0.7.17"

# BUILD_CMD: docker build --pull -t bwa:0.7.17-ubuntu .

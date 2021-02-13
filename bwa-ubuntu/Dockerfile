FROM ubuntu:20.04 AS builder

# Download and install mamba into /usr/bin
ENV MAMBAFORGE_VERSION=4.9.2-5
RUN apt-get update && apt-get install -y curl && \
    curl -sL https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-pypy3-Linux-x86_64.sh -o /tmp/mambaforge.sh && \
    sh /tmp/mambaforge.sh -bfp /usr && rm -f /tmp/mambaforge.sh

# Use mamba to install remaining tools/dependencies into /usr/local
ENV BWA_VERSION=0.7.17
RUN mamba create -qy -p /usr/local \
        -c bioconda \
        bwa==${BWA_VERSION}

# Deploy the target tools into a base image
FROM ubuntu:20.04
COPY --from=builder /usr/local /usr/local

ARG GIT_COMMIT
LABEL org.opencontainers.image.authors="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.opencontainers.image.source="https://github.com/ucladx/dockerfiles/tree/"$GIT_COMMIT"/bwa-ubuntu/Dockerfile" \
    org.opencontainers.image.revision=$GIT_COMMIT

# BUILD_CMD: docker build --pull --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) -t bwa:0.7.17-ubuntu .

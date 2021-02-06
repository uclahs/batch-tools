FROM clearlinux:latest AS builder

# Install a minimal versioned OS into /install_root
ENV CLEAR_VERSION=34220
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Download and install conda into /usr/bin
ENV MINICONDA_VERSION=py37_4.9.2
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    sh /tmp/miniconda.sh -bfp /usr

# Use conda to install remaining tools/dependencies into /usr/local
ENV GATK_VERSION=4.1.9.0
RUN conda create -qy -p /usr/local \
        -c bioconda \
        gatk4==${GATK_VERSION}

# Deploy the minimal OS and target app(s) into a clean image
FROM scratch

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.gatk4="4.1.9.0"

COPY --from=builder /install_root /
COPY --from=builder /usr/local /usr/local

# BUILD_CMD: docker build --pull -t gatk:4.1.9.0 .

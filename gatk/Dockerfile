FROM clearlinux:latest AS builder

# Download and install mamba into /usr/bin
ENV MAMBAFORGE_VERSION=4.9.2-5
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-pypy3-Linux-x86_64.sh -o /tmp/mambaforge.sh && \
    sh /tmp/mambaforge.sh -bfp /usr && rm -f /tmp/mambaforge.sh

# Install a minimal versioned OS into /install_root
ENV CLEAR_VERSION=34250
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Use mamba to install remaining tools/dependencies into /usr/local
ENV GATK_VERSION=4.1.9.0
RUN mamba create -qy -p /usr/local \
        -c bioconda \
        gatk4==${GATK_VERSION}

# Deploy the minimal OS and target tools into a blank image
FROM scratch
COPY --from=builder /install_root /
COPY --from=builder /usr/local /usr/local

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.gatk="4.1.9.0"

# BUILD_CMD: docker build --pull -t gatk:4.1.9.0 .

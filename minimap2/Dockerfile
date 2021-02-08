FROM clearlinux:latest AS builder

# Download and install conda into /usr/bin
ENV MINICONDA_VERSION=py37_4.9.2
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    sh /tmp/miniconda.sh -bfp /usr

# Install a minimal versioned OS into /install_root
ENV CLEAR_VERSION=34250
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Use conda to install remaining tools/dependencies into /usr/local
ENV MINIMAP2_VERSION=2.17
RUN conda create -qy -p /usr/local \
        -c bioconda \
        minimap2==${MINIMAP2_VERSION}

# Deploy the minimal OS and target tools into a blank image
FROM scratch
COPY --from=builder /install_root /
COPY --from=builder /usr/local /usr/local

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.minimap2="2.17"

# BUILD_CMD: docker build --pull -t minimap2:2.17 .

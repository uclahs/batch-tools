FROM clearlinux:latest AS builder

# Install a minimal versioned OS into /install_root, and bundled tools if any
ENV CLEAR_VERSION=32820
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Download and install conda into /usr/bin
ENV MINICONDA_VERSION=py38_4.8.2
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    sh /tmp/miniconda.sh -bfp /usr

# Use conda to install remaining tools/dependencies into /usr/local
ENV HTSLIB_VERSION=1.10.2 \
    BCFTOOLS_VERSION=1.10.2 \
    SAMTOOLS_VERSION=1.10
RUN conda create -qy -p /usr/local \
        -c conda-forge \
        -c bioconda \
        -c defaults \
        htslib==${HTSLIB_VERSION} \
        bcftools==${BCFTOOLS_VERSION} \
        samtools==${SAMTOOLS_VERSION}

# Deploy the minimal OS and target app(s) into a clean image
FROM scratch

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.bgzip="1.10.2" \
    org.uclahealth.version.tabix="1.10.2" \
    org.uclahealth.version.bcftools="1.10.2" \
    org.uclahealth.version.samtools="1.10"

COPY --from=builder /install_root /
COPY --from=builder /usr/local /usr/local

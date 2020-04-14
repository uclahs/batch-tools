FROM clearlinux:latest AS builder

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.bgzip="1.10.2" \
    org.uclahealth.version.tabix="1.10.2" \
    org.uclahealth.version.bcftools="1.10.2" \
    org.uclahealth.version.samtools="1.10"

ENV CLEAR_VERSION=32820 \
    MINICONDA_VERSION=py38_4.8.2 \
    HTSLIB_VERSION=1.10.2 \
    BCFTOOLS_VERSION=1.10.2 \
    SAMTOOLS_VERSION=1.10

# Prepare a root directory with minimal app runtimes
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Use conda to install target apps into the minimal root directory
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    sh /tmp/miniconda.sh -bfp /usr/local && \
    conda create -qy -p /install_root/usr/local -c conda-forge -c bioconda -c defaults htslib==${HTSLIB_VERSION} bcftools==${BCFTOOLS_VERSION} samtools==${SAMTOOLS_VERSION}

# Deploy the minimal OS into a clean target layer
FROM scratch
COPY --from=builder /install_root /

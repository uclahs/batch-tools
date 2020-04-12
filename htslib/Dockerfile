FROM clearlinux:latest AS builder

LABEL maintainer="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.uclahealth.version.htslib="1.9" \
    org.uclahealth.version.bcftools="1.9" \
    org.uclahealth.version.samtools="1.9" \
    org.uclahealth.version.tabix="1.9" \
    org.uclahealth.version.bgzip="1.9"

ENV CLEAR_VERSION 32760
ENV MINICONDA_VERSION py38_4.8.2
ENV HTSLIB_VERSION 1.9
ENV BCFTOOLS_VERSION 1.9
ENV SAMTOOLS_VERSION 1.9

# Use the specific OS version with the software bundles we need
RUN swupd update --no-progress --no-boot-update --version ${CLEAR_VERSION}

# Prepare a root directory with minimal app runtimes
RUN mkdir /install_root && \
    swupd os-install --no-progress --no-boot-update \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Use conda to install target apps into the minimal root directory
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    sh /tmp/miniconda.sh -bfp /usr/local && \
    conda install -qy -p /install_root/usr/local -c bioconda htslib==${HTSLIB_VERSION} bcftools==${BCFTOOLS_VERSION} samtools==${SAMTOOLS_VERSION} && \
    conda clean -afy && \
    rm -f /tmp/miniconda.sh

# Deploy the minimal OS into a clean target layer
FROM scratch
COPY --from=builder /install_root /
CMD [ "/bin/bash" ]

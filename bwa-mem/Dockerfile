FROM clearlinux:latest AS builder

# Download and install mamba into /usr/bin
ENV MAMBAFORGE_VERSION=4.9.2-7
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-pypy3-Linux-x86_64.sh -o /tmp/mambaforge.sh && \
    sh /tmp/mambaforge.sh -bfp /usr && rm -f /tmp/mambaforge.sh

# Install a minimal versioned OS into /install_root
ENV CLEAR_VERSION=34440
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Use mamba to install remaining tools/dependencies into /usr/local
ENV BWAMEM_VERSION=2.1 \
    SAMTOOLS_VERSION=1.11
RUN mamba create -qy -p /usr/local \
        -c bioconda \
        bwa-mem2==${BWAMEM_VERSION} \
        samtools==${SAMTOOLS_VERSION}

# Deploy the minimal OS and target tools into a blank image
FROM scratch
COPY --from=builder /install_root /
COPY --from=builder /usr/local /usr/local

ARG GIT_COMMIT
LABEL org.opencontainers.image.authors="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.opencontainers.image.source="https://github.com/ucladx/dockerfiles/tree/"$GIT_COMMIT"/bwa-mem/Dockerfile" \
    org.opencontainers.image.revision=$GIT_COMMIT

# BUILD_CMD: docker build --pull --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) -t bwa-mem:2.1 .

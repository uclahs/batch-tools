FROM clearlinux:latest AS builder

# Download and install mamba into /usr/bin
ENV MAMBAFORGE_VERSION=4.10.1-4
RUN swupd bundle-add --no-progress curl && \
    curl -sL https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-pypy3-Linux-x86_64.sh -o /tmp/mambaforge.sh && \
    sh /tmp/mambaforge.sh -bfp /usr && rm -f /tmp/mambaforge.sh

# Install a minimal versioned OS into /install_root
ENV CLEAR_VERSION=34730
RUN swupd os-install --no-progress --no-boot-update --no-scripts \
    --version ${CLEAR_VERSION} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core

# Use mamba to install remaining tools/dependencies into /usr/local
ENV PICARD_VERSION=2.25.5
RUN mamba create -qy -p /usr/local \
        -c bioconda \
        picard-slim==${PICARD_VERSION}

# Deploy the minimal OS and target tools into a blank image
FROM scratch
COPY --from=builder /install_root /
COPY --from=builder /usr/local /usr/local

ARG GIT_COMMIT
LABEL org.opencontainers.image.authors="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.opencontainers.image.source="https://github.com/uclahs/dockerfiles/tree/"$GIT_COMMIT"/picard/Dockerfile" \
    org.opencontainers.image.revision=$GIT_COMMIT

# BUILD_CMD: docker build --pull --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) -t picard:2.25.5 .

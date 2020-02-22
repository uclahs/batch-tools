FROM clearlinux:latest AS builder

# Allow arguments (e.g. --version) into swupd as it updates OS
ARG swupd_args
RUN swupd update --no-progress --no-boot-update $swupd_args

# Install bundles needed to download and build app
RUN swupd bundle-add --no-progress curl \
    devpkg-bzip2 \
    devpkg-xz \
    devpkg-ncurses \
    devpkg-curl \
    devpkg-openssl \
    samtools

# Prepare a root directory with minimal app runtimes
RUN source /usr/lib/os-release && \
    mkdir /install_root && \
    swupd os-install --no-progress --no-boot-update \
    --version ${VERSION_ID} \
    --path /install_root \
    --statedir /swupd-state \
    --bundles os-core,samtools

# Build app and install into the minimal root directory
RUN HTSLIB_VERSION=`bcftools version | grep -E '^Using htslib' | cut -d' ' -f3` && \
    cd /tmp && \
    curl -sLO https://github.com/samtools/htslib/archive/${HTSLIB_VERSION}.tar.gz && \
    tar -zxf ${HTSLIB_VERSION}.tar.gz && \
    cd /tmp/htslib-${HTSLIB_VERSION} && \
    make -j4 prefix=/install_root/usr install

# Deploy the minimal OS into a clean target layer
FROM scratch
COPY --from=builder /install_root /
CMD [ "/bin/bash" ]

FROM centos:centos7.9.2009 AS builder

# Download and install the target tool into base image and cleanup
ENV BCL_CONVERT_VERSION=3.8.2
RUN curl -sL https://data.cyri.ac/bcl-convert_v${BCL_CONVERT_VERSION}.rpm -o /tmp/bcl-convert.rpm && \
    yum install -y -q gdb && \
    rpm -i /tmp/bcl-convert.rpm && \
    rm /tmp/bcl-convert.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum

# Deploy the filesystem into a blank image to clear labels from the builder image
FROM scratch
COPY --from=builder / /

ARG GIT_COMMIT
LABEL org.opencontainers.image.authors="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.opencontainers.image.source="https://github.com/uclahs/batch-tools/tree/"$GIT_COMMIT"/bcl-convert/Dockerfile" \
    org.opencontainers.image.revision=$GIT_COMMIT

# BUILD_CMD: docker build --pull --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) -t bcl-convert:3.8.2 .

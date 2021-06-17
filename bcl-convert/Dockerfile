FROM centos:centos7.9.2009

# Download and install the target tool into base image and cleanup
ENV BCL_CONVERT_VERSION=3.8.2
RUN curl -sL https://data.cyri.ac/bcl-convert_v${BCL_CONVERT_VERSION}.rpm -o /tmp/bcl-convert.rpm && \
    yum install -y -q gdb && \
    rpm -i /tmp/bcl-convert.rpm && \
    rm /tmp/bcl-convert.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum

ARG GIT_COMMIT
LABEL org.opencontainers.image.authors="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.opencontainers.image.source="https://github.com/uclahs/dockerfiles/tree/"$GIT_COMMIT"/bcl-convert/Dockerfile" \
    org.opencontainers.image.revision=$GIT_COMMIT

# BUILD_CMD: docker build --pull --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) -t bcl-convert:3.8.2 .

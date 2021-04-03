FROM centos:7

# Download and install bcl-convert into /usr/local
ENV BCL_CONVERT_VERSION=3.7.5
RUN curl -sL https://data.cyri.ac/bcl-convert_v${BCL_CONVERT_VERSION}.rpm -o /tmp/bcl-convert.rpm && \
    yum update -y -q && \
    yum groups mark install -y -q "Development Tools" && \
    yum groups mark convert -y -q "Development Tools" && \
    yum groupinstall -y -q "Development Tools" && \
    rpm -i /tmp/bcl-convert.rpm && \
    rm /tmp/bcl-convert.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum

ARG GIT_COMMIT
LABEL org.opencontainers.image.authors="Cyriac Kandoth <ckandoth@gmail.com>" \
    org.opencontainers.image.source="https://github.com/ucladx/dockerfiles/tree/"$GIT_COMMIT"/bcl-convert/Dockerfile" \
    org.opencontainers.image.revision=$GIT_COMMIT

# BUILD_CMD: docker build --pull --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) -t bcl-convert:3.7.5 .

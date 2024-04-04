#
# Builds the toxic/ubuntu-22.04 toolchain container.
#
FROM ubuntu:22.04 AS base

LABEL org.opencontainers.image.source=https://github.com/OpenCyphal/docker_toolchains
LABEL org.opencontainers.image.description="Provides a consistent build and test environment for development, continuous-integration, and test automation of OpenCyphal Python based projects."
LABEL org.opencontainers.image.licenses=MIT

VOLUME /repo

WORKDIR /repo

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# +---------------------------------------------------------------------------+
# | UBUNTU PROVISIONING
# +---------------------------------------------------------------------------+
FROM base AS provisioning
WORKDIR /tmp
ADD pre-provision.sh ./pre-provision.sh
ADD provision.sh ./provision.sh
ADD post-provision.sh ./post-provision.sh

RUN ./pre-provision.sh
RUN ./provision.sh
RUN ./pre-provision.sh



# +---------------------------------------------------------------------------+
# | FINALIZE
# +---------------------------------------------------------------------------+
FROM provisioning AS all

# INSTALL THE PATH FOR INTERATIVE SESSIONS
RUN echo "export PATH=$PATH" >> ~/.bashrc

# LEAVE THE WORKDIR AS /repo
WORKDIR /repo

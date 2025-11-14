# Multi-stage Dockerfile for BlazeNeuro Linux build
FROM ubuntu:22.04 AS base

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential bison flex texinfo gawk wget \
    libncurses-dev bc libssl-dev libelf-dev \
    libgmp-dev libmpfr-dev libmpc-dev \
    python3 python3-pip gettext autoconf automake \
    libtool pkg-config m4 rsync xz-utils \
    passwd sudo \
    && rm -rf /var/lib/apt/lists/*

# Create LFS directory structure
RUN mkdir -p /mnt/lfs/{tools,sources,build,usr,boot,etc,var,home} && \
    mkdir -p /mnt/lfs/usr/{bin,lib,sbin} && \
    ln -sf usr/bin /mnt/lfs/bin && \
    ln -sf usr/lib /mnt/lfs/lib && \
    ln -sf usr/sbin /mnt/lfs/sbin

# Set environment
ENV LFS=/mnt/lfs \
    LFS_TGT=x86_64-lfs-linux-gnu \
    LC_ALL=POSIX \
    PATH=/mnt/lfs/tools/bin:/usr/bin:/bin

WORKDIR /build

# Copy project files
FROM base AS builder
COPY . /build/
RUN chmod +x /build/build.sh /build/scripts/stages/*.sh

# Create logs directory and build
RUN mkdir -p /build/logs && /build/build.sh all || (cat /build/logs/build.log 2>/dev/null && exit 1)

# Create final artifact
FROM builder AS packager
RUN cd /mnt/lfs && \
    tar czf /blazeneuro-rootfs.tar.gz . && \
    echo "Build completed successfully"

# Final stage - just the artifact
FROM scratch AS export
COPY --from=packager /blazeneuro-rootfs.tar.gz /

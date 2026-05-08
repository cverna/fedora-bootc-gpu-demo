# GPU Worker Node - Fedora bootc with NVIDIA drivers
#
# This image derives from the CoreOS NVIDIA base image and adds
# cloud-init for AWS compatibility and a default user.
#
# Build: podman build --build-arg-file build-args.conf -t gpu-worker .
# Deploy: bootc switch ghcr.io/<your-user>/fedora-bootc-gpu-demo:latest

ARG STREAM=43
ARG DRIVER_VERSION=595.58.03
ARG IMAGE_USER=core

FROM quay.io/coreos-devel/fedora-bootc-nvidia:${STREAM}-${DRIVER_VERSION}

ARG IMAGE_USER

# Add cloud-init for AWS SSH key injection
# Note: cloud-init package's post-install script already enables the services
RUN dnf install -y cloud-init && \
    dnf clean all

# Create default user (matches FCOS default for AWS)
RUN useradd -m -G wheel -s /bin/bash ${IMAGE_USER} && \
    echo "${IMAGE_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${IMAGE_USER}

# Validate the image meets bootc requirements
RUN bootc container lint

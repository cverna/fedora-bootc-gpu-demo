# GPU Worker Node - Fedora bootc with NVIDIA drivers
#
# This image derives from the CoreOS NVIDIA base image and adds
# cloud-init for AWS compatibility.
#
# Build: podman build --build-arg-file build-args.conf -t gpu-worker .
# Deploy: bootc switch ghcr.io/<your-user>/fedora-bootc-gpu-demo:latest

ARG STREAM=43
ARG DRIVER_VERSION=595.58.03

FROM quay.io/coreos-devel/fedora-bootc-nvidia:${STREAM}-${DRIVER_VERSION}

# Add cloud-init for AWS SSH key injection
# Note: cloud-init package's post-install script already enables the services
RUN dnf install -y cloud-init && \
    dnf clean all

# Blacklist nouveau driver to allow NVIDIA proprietary driver to bind
RUN echo -e "blacklist nouveau\noptions nouveau modeset=0" > /usr/lib/modprobe.d/blacklist-nouveau.conf

# Validate the image meets bootc requirements
RUN bootc container lint

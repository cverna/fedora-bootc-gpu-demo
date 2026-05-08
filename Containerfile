# GPU Worker Node - Fedora bootc with NVIDIA drivers
#
# This image derives from the CoreOS NVIDIA base image and adds
# cloud-init for AWS compatibility and CUDA userspace tools.
#
# Build: podman build --build-arg-file build-args.conf -t gpu-worker .
# Deploy: bootc switch ghcr.io/<your-user>/fedora-bootc-gpu-demo:latest

ARG STREAM=43
ARG DRIVER_VERSION=595.58.03

FROM quay.io/coreos-devel/fedora-bootc-nvidia:${STREAM}-${DRIVER_VERSION}

# Re-declare ARG after FROM (ARGs are reset after FROM)
ARG DRIVER_VERSION

# Add cloud-init for AWS SSH key injection
RUN dnf install -y cloud-init && \
    dnf clean all

# Blacklist nouveau driver to allow NVIDIA proprietary driver to bind
RUN echo -e "blacklist nouveau\noptions nouveau modeset=0" > /usr/lib/modprobe.d/blacklist-nouveau.conf

# Add NVIDIA CUDA repository and install userspace tools (nvidia-smi, etc.)
RUN source /usr/lib/os-release && \
    curl -s https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID}/$(arch)/cuda-${ID}${VERSION_ID}.repo \
         -o /etc/yum.repos.d/cuda.repo && \
    dnf install -y \
        nvidia-driver-cuda-${DRIVER_VERSION} \
        nvidia-driver-cuda-libs-${DRIVER_VERSION} && \
    dnf clean all

# Validate the image meets bootc requirements
RUN bootc container lint

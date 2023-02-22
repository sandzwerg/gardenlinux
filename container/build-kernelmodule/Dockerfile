ARG VERSION
ARG build_base_image=gardenlinux/build-image:${VERSION}
FROM $build_base_image

SHELL ["/bin/bash", "-c"]
ARG KERNEL_VERSION
ARG KERNEL_BASE
ARG JOB_HOST_GNU_TYPE_PACKAGE
ARG JOB_HOST_ARCH

RUN dpkg --add-architecture $JOB_HOST_ARCH

RUN apt-get update -qy
RUN apt-get install -qy sudo vim git rsync wget curl gnupg python3 build-essential bc kmod cpio \
			flex libncurses5-dev libelf-dev libssl-dev dwarves \
            devscripts kernel-wedge pristine-lfs python3-debian quilt dkms

RUN apt-get install -qy --no-install-recommends \ 
        binutils-$JOB_HOST_GNU_TYPE_PACKAGE gcc-$JOB_HOST_GNU_TYPE_PACKAGE \
        g++-$JOB_HOST_GNU_TYPE_PACKAGE libc6-dev:$JOB_HOST_ARCH

RUN : "Include experimental distribution for kpatch" \
                && echo "deb https://cdn-aws.deb.debian.org/debian experimental main" >> /etc/apt/sources.list \
                && apt-get update

RUN : "Install kpatch" \
                && apt-get install -qy --no-install-recommends \
                kpatch-build


RUN mv /bin/uname /bin/uname-orig
ADD ./bin/* /bin/

RUN echo "KERNEL_BASE=${KERNEL_BASE}" >> ~/.bashrc
RUN echo "KERNEL_FLAVOUR=${KERNEL_FLAVOUR}"ho $K ~/.bashrc

# Install kernel headers for all supported arch+flavour combinations
RUN apt-get update -qy
RUN TARGET_HEADER="$(KERNEL_ARCH=$JOB_HOST_ARCH KERNEL_FLAVOUR=cloud /bin/garden-latest-dev-kernel-header-package)" && \
    apt-get install -qy "${TARGET_HEADER}"; 

RUN TARGET_HEADER="$(KERNEL_ARCH=$JOB_HOST_ARCH /bin/garden-latest-dev-kernel-header-package)" && \
    apt-get install -qy "${TARGET_HEADER}"; 
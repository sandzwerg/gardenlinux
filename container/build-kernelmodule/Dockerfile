ARG VERSION
ARG build_base_image=gardenlinux/build-image:${VERSION}
FROM $build_base_image

ARG KERNEL_BASE
ARG TARGET_ARCH_GNU_TYPE_PACKAGE
ARG TARGET_ARCH

RUN dpkg --add-architecture $TARGET_ARCH

# TODO: remove when image is not based on debian anymore but gardenlinux
ADD ./gardenlinux-apt-preferences /etc/apt/preferences.d/gardenlinux

RUN apt-get update -qy \
			&& apt-get install -qy sudo vim git rsync wget curl gnupg python3 build-essential bc kmod cpio \
						flex libncurses5-dev libelf-dev libssl-dev dwarves \
						devscripts kernel-wedge pristine-lfs python3-debian quilt dkms

RUN apt-get install -qy --no-install-recommends \ 
			binutils-$TARGET_ARCH_GNU_TYPE_PACKAGE gcc-$TARGET_ARCH_GNU_TYPE_PACKAGE \
			g++-$TARGET_ARCH_GNU_TYPE_PACKAGE libc6-dev:$TARGET_ARCH
 
RUN mv /bin/uname /bin/uname-orig
ADD ./bin/* /bin/

RUN apt-get update -qy
RUN apt-get install -qy \
			"linux-kbuild-${KERNEL_BASE}" \
			"linux-headers-${KERNEL_BASE}-${TARGET_ARCH}" \
			"linux-source-${KERNEL_BASE}"

RUN : "Install kpatch-build from experimental" \
			&& echo "deb https://cdn-aws.deb.debian.org/debian experimental main" >> /etc/apt/sources.list \
			&& apt-get update \
			&& apt-get install -qy --no-install-recommends kpatch-build

#!/bin/bash
#File: installobs.sh (sudo chmod +x installobs.sh)

WORK_DIR=~/obs-build\
PREFIX=/usr\
APT_DEPS=(build-essential \
	checkinstall \
	cmake \
	git \
	libmbedtls-dev \
	libasound2-dev \
	libavcodec-dev \
	libavdevice-dev \
	libavfilter-dev \
	libavformat-dev \
	libavutil-dev \
	libcurl4-openssl-dev \
	libfontconfig1-dev \
	libfreetype6-dev \
	libgl1-mesa-dev \
	libjack-jackd2-dev \
	libjansson-dev \
	libluajit-5.1-dev \
	libpulse-dev \
	libqt5x11extras5-dev \
	libspeexdsp-dev \
	libswresample-dev \
	libswscale-dev \
	libudev-dev \
	libv4l-dev \
	libvlc-dev \
	libx11-dev \
	libx11-xcb1 \
	libx11-xcb-dev \
	libxcb-xinput0 \
	libxcb-xinput-dev \
	libxcb-randr0 \
	libxcb-randr0-dev \
	libxcb-xfixes0 \
	libxcb-xfixes0-dev \
	libx264-dev \
	libxcb-shm0-dev \
	libxcb-xinerama0-dev \
	libxcomposite-dev \
	libxinerama-dev \
	pkg-config \
	python3-dev \
	qtbase5-dev \
	libqt5svg5-dev \
	swig)\
\
echo "-----------------------------------"\
echo "    Making working directory"\
echo "-----------------------------------"\
mkdir -p "$WORK_DIR"\
cd "$WORK_DIR"\
\
echo "-----------------------------------"\
echo "Updating system and installing deps"\
echo "-----------------------------------"\
sudo apt-get --allow-releaseinfo-change update\
sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade\
sudo apt-get -y install $\{APT_DEPS[@]\}\
wget http://ftp.uk.debian.org/debian/pool/non-free/f/fdk-aac/libfdk-aac1_0.1.4-2+b1_armhf.deb\
wget http://ftp.uk.debian.org/debian/pool/non-free/f/fdk-aac/libfdk-aac-dev_0.1.4-2+b1_armhf.deb\
sudo dpkg -i libfdk-aac1_0.1.4-2+b1_armhf.deb\
sudo dpkg -i libfdk-aac-dev_0.1.4-2+b1_armhf.deb\
\
echo "-----------------------------------"\
echo "        Getting OBS Source"\
echo "-----------------------------------"\
git clone --recursive https://github.com/obsproject/obs-studio.git\
\
echo "-----------------------------------"\
echo "       Getting simde-math.h"\
echo "-----------------------------------"\
git clone https://github.com/simd-everywhere/simde.git\
cp simde/simde/simde-math.h obs-studio/libobs/util/simde\
\
echo "-----------------------------------"\
echo "         Preparing build"\
echo "-----------------------------------"\
cd obs-studio\
mkdir build && cd build\
cmake -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX="$PREFIX" ..\
\
echo "-----------------------------------"\
echo "             Building"\
echo "-----------------------------------"\
make -j4\
sudo make install\
\
echo "-----------------------------------"\
echo "        Changing OBS for ARM"\
echo "-----------------------------------"\
\
git clone https://github.com/jratcliff63367/sse2neon.git\
sudo cp sse2neon/SSE2NEON.h /usr/include/obs/util/sse2neon.h\
git clone https://github.com/venepe/obs-lib-hack.git\
sudo cp ./obs-lib-hack/graphics/vec3.h /usr/include/obs/graphics/vec3.h\
sudo cp ./obs-lib-hack/graphics/vec4.h /usr/include/obs/graphics/vec4.h\
sudo cp ./obs-lib-hack/util/sse-intrin.h /usr/include/obs/util/sse-intrin.h\
\
echo "-----------------------------------"\
echo "        Installing NDI"\
echo "-----------------------------------"\
\
git clone https://github.com/venepe/install-libndi.git\
cd ./install-libndi\
sudo chmod +x ./install-libndi.sh\
./install-libndi.sh\
cd ..\
echo "-----------------------------------"\
echo "        Copy NDI to Usr Lib"\
echo "-----------------------------------"\
\
sudo cp /tmp/ndisdk/lib/arm-rpi3-linux-gnueabihf/libndi.so /usr/lib/libndi.so\
sudo cp /tmp/ndisdk/lib/arm-rpi3-linux-gnueabihf/libndi.so.4 /usr/lib/libndi.so.4\
sudo cp /tmp/ndisdk/lib/arm-rpi3-linux-gnueabihf/libndi.so.4.5.1 /usr/lib/libndi.so.4.5.1\
echo "-----------------------------------"\
echo "        Installing OBS NDI"\
echo "-----------------------------------"\
\
git clone https://github.com/venepe/obs-ndi.git\
cd obs-ndi/\
mkdir build && cd build\
cmake -DLIBOBS_INCLUDE_DIR="/usr/share/obs/libobs/" -DCMAKE_INSTALL_PREFIX=/usr ..\
make -j4\
sudo make install\
cd ../../\
echo "-----------------------------------"\
echo "        Installing OBS Websockets"\
echo "-----------------------------------"\
\
git clone https://github.com/venepe/obs-websocket.git\
cd obs-websocket/\
mkdir build && cd build\
cmake -DLIBOBS_INCLUDE_DIR="/usr/share/obs/libobs/" -DCMAKE_INSTALL_PREFIX=/usr -DUSE_UBUNTU_FIX=true ..\
make -j4\
sudo make install\
obs #only need to run this command from now on\
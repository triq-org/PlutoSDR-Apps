#!/bin/bash

set -e

FIRMWARE=${FIRMWARE:=0.38}

export builddir="${builddir:-$(pwd)}"

date +%F >"${builddir}/RELEASE-VERSION.txt"
export releaseinfo="${builddir}/RELEASE-INFO.md"
echo -n >"${releaseinfo}"

# Setup Toolchain

if [ -z "${tools}" -a -n "$(command -v arm-linux-gnueabihf-gcc)" ] ; then
  export tools=$(dirname $(dirname $(command -v arm-linux-gnueabihf-gcc)))
  echo "- Compiler: $(arm-linux-gnueabihf-gcc --version | head -1)" >>"${releaseinfo}"
fi

if [ -z "${tools}" -a -d "gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf" ] ; then
  export tools="${builddir}/gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf"
  export PATH="${tools}/bin:$PATH"
  echo '- Compiler: gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf' >>"${releaseinfo}"
fi

if [ -z "${tools}" -a -d "gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf" ] ; then
  export tools="${builddir}/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf"
  export PATH="${tools}/bin:$PATH"
  echo '- Compiler: gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf' >>"${releaseinfo}"
fi

if [ -z "${tools}" -a -d "/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi" ] ; then
  export tools="/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi"
  export PATH="${tools}/bin:$PATH"
  echo "- Compiler: $(arm-linux-gnueabihf-gcc --version | head -1)" >>"${releaseinfo}"
fi

if [ -z "${tools}" ] ; then
  echo 'Toolchain "arm-linux-gnueabihf" not found. On Debian try:'
  echo '$ sudo apt-get install -y crossbuild-essential-armhf'
  echo 'Or a standalone toolchain:'
  echo '$ wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2019.01/gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf.tar.xz'
  echo '$ tar xf gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf.tar.xz'
  echo 'Or for newer firmware versions:'
  echo '$ wget https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabihf/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz'
  echo '$ tar xf gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz'
  exit 1
fi

# Setup Sysroot

if [ ! -d staging ] ; then
  [ -f sysroot-v${FIRMWARE}.tar.gz ] || wget https://github.com/analogdevicesinc/plutosdr-fw/releases/download/v${FIRMWARE}/sysroot-v${FIRMWARE}.tar.gz
  tar xzf sysroot-v${FIRMWARE}.tar.gz
fi
echo "- plutosdr-fw: sysroot v${FIRMWARE}" >>"${releaseinfo}"
export sysroot="${sysroot:-${builddir}/staging}"
export stagedir="${stagedir:-${builddir}/stage}"
export toolchain="${toolchain:-${builddir}/Toolchain-arm-linux-gnueabi.cmake}"

# Compile Apps

#export CFLAGS="-Werror"
#export CXXFLAGS="-Werror -Wno-psabi"

[ -d SoapySDR ] || git clone --depth 1 https://github.com/pothosware/SoapySDR.git
pushd SoapySDR
echo -n '- SoapySDR: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_PYTHON=OFF -DENABLE_PYTHON3=OFF -B build
cmake --build build -- install
popd

[ -d SoapyPlutoSDR ] || git clone --depth 1 https://github.com/pothosware/SoapyPlutoSDR.git
pushd SoapyPlutoSDR
echo -n '- SoapyPlutoSDR: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" -B build
cmake --build build -- install
popd

[ -d SoapyRemote ] || git clone --depth 1 https://github.com/pothosware/SoapyRemote.git
pushd SoapyRemote
echo -n '- SoapyRemote: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" -B build
cmake --build build -- install
popd

[ -d rtl_433 ] || git clone --depth 1 https://github.com/merbanan/rtl_433.git
pushd rtl_433
echo -n '- rtl_433: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build
cmake -DENABLE_RTLSDR=OFF -DENABLE_SOAPYSDR=ON -DENABLE_OPENSSL=OFF -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" -B build
cmake --build build -- install
popd

[ -d rx_tools ] || git clone --depth 1 https://github.com/rxseger/rx_tools.git
pushd rx_tools
echo -n '- rx_tools: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" -B build
cmake --build build -- install
popd

[ -d tx_tools ] || git clone --depth 1 https://github.com/triq-org/tx_tools.git
pushd tx_tools
echo -n '- tx_tools: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" -B build
cmake --build build -- install
popd

# Note: dumb http transport does not support shallow capabilities
[ -d chrony ] || git clone https://git.tuxfamily.org/chrony/chrony.git
pushd chrony
echo -n '- chrony: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
CC="arm-linux-gnueabihf-gcc" CFLAGS="--sysroot ${sysroot}" ./configure --prefix=/usr
# sudo apt-get install -y bison
make
# make install DESTDIR=${stagedir} BINDIR=/bin SBINDIR=/bin
cp -a chronyc chronyd "${stagedir}/bin/"
popd

[ -d gpsd ] || git clone --depth 1 git://git.savannah.gnu.org/gpsd.git
pushd gpsd
echo -n '- gpsd: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
# sudo apt-get install -y scons
DESTDIR="${stagedir}" scons libgpsmm=No ncurses=No python=No sbindir=bin prefix=/ sysroot="${sysroot}" target=arm-linux-gnueabihf build install
popd

[ -d iperf ] || git clone --depth 1 https://github.com/esnet/iperf.git
pushd iperf
echo -n '- iperf: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
CFLAGS="--sysroot ${sysroot}" ./configure --without-openssl --prefix=/usr --host=arm-linux-gnueabihf --enable-static --disable-shared
make
make install DESTDIR=${stagedir} prefix=/
popd

[ -d socat ] || git clone --depth 1 git://repo.or.cz/socat.git
pushd socat
echo -n '- socat: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
autoconf
CFLAGS="--sysroot ${sysroot}" ./configure --disable-openssl --prefix=/usr --host=arm-linux-gnueabihf
# this might be wrongly detected
echo '#undef HAVE_SYS_STROPTS_H' >>config.h
# sudo apt-get install -y yodl
make
make install DESTDIR=${stagedir} prefix=/
popd

# Dist Package

cd "${stagedir}"
find . -ls
tar czf "${builddir}/plutosdr-apps.tar.gz" bin lib/lib* lib/SoapySDR

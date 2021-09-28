#!/bin/bash

set -e

export builddir="${builddir:-$(pwd)}"

date +%F >"${builddir}/RELEASE-VERSION.txt"
export releaseinfo="${builddir}/RELEASE-INFO.md"
echo -n >"${releaseinfo}"

if [ ! -d gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf ] ; then
  [ -f gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf.tar.xz ] || wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2019.01/gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf.tar.xz
  tar xf gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf.tar.xz
fi
echo '- Compiler: gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf' >>"${releaseinfo}"
export tools="${tools:-${builddir}/gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf}"

if [ ! -d staging ] ; then
  [ -f sysroot-v0.34.tar.gz ] || wget https://github.com/analogdevicesinc/plutosdr-fw/releases/download/v0.34/sysroot-v0.34.tar.gz
  tar xzf sysroot-v0.34.tar.gz
fi
echo '- plutosdr-fw: sysroot v0.34' >>"${releaseinfo}"
export sysroot="${sysroot:-${builddir}/staging}"
export stagedir="${stagedir:-${builddir}/stage}"
export toolchain="${toolchain:-${builddir}/Toolchain-arm-linux-gnueabi.cmake}"

[ -d SoapySDR ] || git clone https://github.com/pothosware/SoapySDR.git
pushd SoapySDR
echo -n '- SoapySDR: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build ; pushd build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_PYTHON=OFF -DENABLE_PYTHON3=OFF .. && make && make install
popd ; popd

[ -d SoapyPlutoSDR ] || git clone https://github.com/pothosware/SoapyPlutoSDR.git
pushd SoapyPlutoSDR
echo -n '- SoapyPlutoSDR: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build ; pushd build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" .. && make && make install
popd ; popd

[ -d SoapyRemote ] || git clone https://github.com/pothosware/SoapyRemote.git
pushd SoapyRemote
echo -n '- SoapyRemote: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build ; pushd build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" .. && make && make install
popd ; popd

[ -d rtl_433 ] || git clone https://github.com/merbanan/rtl_433.git
pushd rtl_433
echo -n '- rtl_433: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build ; pushd build
cmake -DENABLE_RTLSDR=OFF -DENABLE_SOAPYSDR=ON -DENABLE_OPENSSL=OFF -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" .. && make && make install
popd ; popd

[ -d rx_tools ] || git clone https://github.com/rxseger/rx_tools.git
pushd rx_tools
echo -n '- rx_tools: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build ; pushd build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" .. && make && make install
popd ; popd

[ -d tx_tools ] || git clone https://github.com/triq-org/tx_tools.git
pushd tx_tools
echo -n '- tx_tools: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
rm -rf build ; mkdir build ; pushd build
cmake -DCMAKE_TOOLCHAIN_FILE="${toolchain}" -DCMAKE_INSTALL_PREFIX=/usr -DSoapySDR_DIR="${stagedir}/share/cmake/SoapySDR" .. && make && make install
popd ; popd

[ -d chrony ] || git clone https://git.tuxfamily.org/chrony/chrony.git
pushd chrony
echo -n '- chrony: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
export CROSS_COMPILE="${tools}/bin/arm-linux-gnueabihf-"
CC="${CROSS_COMPILE}gcc" CFLAGS="--sysroot ${sysroot}" ./configure --prefix=/usr
# sudo apt-get install -y bison
make
# make install DESTDIR=${stagedir}
cp chronyc chronyd "${stagedir}/bin/"
popd

[ -d gpsd ] || git clone git://git.savannah.gnu.org/gpsd.git
pushd gpsd
echo -n '- gpsd: ' >>"${releaseinfo}"
git describe --tags --first-parent --abbrev=7 --long --dirty --always >>"${releaseinfo}"
# sudo apt-get install -y scons
export PATH="$tools/bin:$PATH"
DESTDIR="${stagedir}" scons libgpsmm=No ncurses=No python=No prefix=/usr sysroot="${sysroot}" target=arm-linux-gnueabihf build install
# fix paths
rsync -a "${stagedir}/usr/" "${stagedir}/"
popd

cd "${stagedir}"
find . -ls
tar czf "${builddir}/plutosdr-apps.tar.gz" bin etc lib sbin

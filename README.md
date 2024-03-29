# Prebuilt SoapySDR and rtl_433 apps for Pluto SDR

This is a build action to create [binary releases](https://github.com/triq-org/PlutoSDR-Apps/releases)
for the [ADALM-Pluto SDR](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adalm-pluto.html#eb-overview).

You mainly get [SoapySDR](https://github.com/pothosware/SoapySDR/),
the [SoapyPlutoSDR](https://github.com/pothosware/SoapyPlutoSDR/) module,
and [rtl_433](https://github.com/merbanan/rtl_433).
But there is also
[rx_tools](https://github.com/rxseger/rx_tools),
[tx_tools](https://github.com/triq-org/tx_tools),
[SoapyRemote](https://github.com/pothosware/SoapyRemote),
[chrony](https://chrony.tuxfamily.org/),
[gpsd](https://gitlab.com/gpsd/gpsd),
and for testing
[iperf](https://github.com/esnet/iperf),
[socat](http://repo.or.cz/socat).
Let me know what other tools would be useful.

## Using

Download [a Release](https://github.com/triq-org/PlutoSDR-Apps/releases),
then copy to the Pluto and unpack to `/usr`

```
$ wget https://github.com/triq-org/PlutoSDR-Apps/releases/download/2024-02-23/plutosdr-apps-2024-02-23.tar.gz
$ gzip -dc plutosdr-apps-2024-02-23.tar.gz |ssh root@pluto "cd /usr ; tar xv"
$ ssh root@pluto
# SoapySDRUtil --args="driver=plutosdr" --rate=50000000 --direction=RX
# SoapySDRServer --bind
$ SoapySDRUtil --args="driver=remote,remote=192.168.2.1,remote:driver=plutosdr" --rate=4000000 --direction=RX
```

## Notes on the compiler toolchain

If you want to compile yourself you need a compiler toolchain.
You want a host target of `arm-linux-gnueabihf`, a number of options are available:

### Using Debian (or Ubuntu) crossbuild toolchain

Simply install the `crossbuild-essential-armhf` meta package.

Toolchain path will be `/usr` and is already setup.

### Using ARM.com toolchain (previously Linaro)

You can use the ARM.com (previously Linaro) supplied compiler.

See [GNU Toolchain for the A-profile Architecture](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads).
The `8.2-2019.01` version could work. You want the download "AArch32 target with hard float (arm-linux-gnueabihf)", then just unpack.

Toolchain path will be `DESTDIR/gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf`

## Using GNU Toolchain releases from Linaro

Newer versions of the Pluto firmware don't use GCC 8.2.0 anymore but GCC 7.3 now.

See [Arm GNU Toolchain Downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
for [GNU Toolchain releases from Linaro (discontinued)](https://releases.linaro.org/components/toolchain/binaries/).
The `7.3-2018.05` version should work. You want the download "arm-linux-gnueabihf", then just unpack.

Toolchain path will be `DESTDIR/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf`

### Using Xilinx 2019.1 SDK toolchain

You can use the Xilinix provided compiler.
The download needs an account though and there is no easy unattended install.

See [Xilinx Software Development Kit (XSDK)](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/archive-sdk.html).
You want the Software Development Kit Standalone WebInstall Client - 2019.1  Lightweight Installer Download,
then run `sh Xilinx_SDK_2019.1_0524_1430_Lin64.bin`

We only need tools from /opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi
You might want to repackage the compiler base dir for unattended install.

Toolchain path will be `/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi`

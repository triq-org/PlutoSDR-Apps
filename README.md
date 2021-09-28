# Prebuilt SoapySDR and rtl_433 apps for Pluto SDR

This is a build action to create [binary releases](https://github.com/triq-org/PlutoSDR-Apps/releases)
for the [ADALM-Pluto SDR](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adalm-pluto.html#eb-overview).

You mainly get [SoapySDR](https://github.com/pothosware/SoapySDR/),
the [SoapyPlutoSDR](https://github.com/pothosware/SoapyPlutoSDR/) module,
and [rtl_433](https://github.com/merbanan/rtl_433).
But there is also [rx_tools](https://github.com/rxseger/rx_tools),
[tx_tools](https://github.com/triq-org/tx_tools),
[SoapyRemote](https://github.com/pothosware/SoapyRemote),
[chrony](https://chrony.tuxfamily.org/),
and [gpsd](https://gitlab.com/gpsd/gpsd) currently.
Let me know what other tools would be useful.

## Using

Download [a Release](https://github.com/triq-org/PlutoSDR-Apps/releases),
then copy to the Pluto and unpack to `/usr`

## Notes on the compiler toolchain

If you want to compile yourself you need a compiler toolchain.

### Using ARM.com toolchain (previously Linaro)

You can use the ARM.com supplied compiler, located in `DESTDIR/gcc-arm-8.2-2019.01-x86_64-arm-linux-gnueabihf`

See [GNU Toolchain for the A-profile Architecture](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads/8-2-2019-01).
You want the download "AArch32 target with hard float (arm-linux-gnueabihf)", then just unpack.

### Using Xilinx 2019.1 SDK toolchain

You can use the Xilinix provided compiler, located in `/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi`
The download needs an account though and there is no easy unattended install.

See [Xilinx Software Development Kit (XSDK)](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/archive-sdk.html).
You want the Software Development Kit Standalone WebInstall Client - 2019.1  Lightweight Installer Download,
then run `sh Xilinx_SDK_2019.1_0524_1430_Lin64.bin`

We only need tools from /opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi
You might want to repackage the compiler base dir for unattended install.

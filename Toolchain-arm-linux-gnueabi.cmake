set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
# Set to plutosdr-fw sysroot dir
if(DEFINED ENV{sysroot})
    set(CMAKE_SYSROOT $ENV{sysroot})
else()
    set(CMAKE_SYSROOT $ENV{HOME}/staging)
endif()
# Set to output dir
if(DEFINED ENV{stagedir})
    set(CMAKE_STAGING_PREFIX $ENV{stagedir})
else()
    set(CMAKE_STAGING_PREFIX $ENV{HOME}/stage)
endif()
# Set for SoapySDR to locate it's module search path (/usr/lib/SoapySDR/modules0.7)
set(CMAKE_INSTALL_PREFIX:PATH /usr)
# Set to cross compiler location
if(DEFINED ENV{tools})
    set(tools $ENV{tools})
else()
    set(tools /opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi)
endif()
set(CMAKE_C_COMPILER ${tools}/bin/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/arm-linux-gnueabihf-g++)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
# Set for Soapy modules and rtl_433 to locate staged SoapySDR libs
set(CMAKE_PREFIX_PATH ${CMAKE_STAGING_PREFIX})
# conda-hdmi2usb-packages

Conda build recipes for HDMI2USB-litex-firmware build dependencies.

Basically, anything which hasn't gotten a proper package at https://launchpad.net/~timvideos/+archive/ubuntu/hdmi2usb

# Toolchains

## LiteX "soft-CPU" support

The LiteX system supports both a `lm32` and `or1k` "soft-CPU" implementations.

Current versions are;

 * binutils - 2.28.0
 * gcc - 5.4.0
 * gcc+newlib - 5.4.0 + 2.4.0
 * gdb - 7.11

### lm32-elf

 * All come from upstream.

### or1k-elf

 * binutils - upstream
 * gcc, newlib & gdb - or1k forks based on upstream version.

## Cypress FX2 support

 * sdcc (Current version: 3.5.0)

# Support Tools

## OpenOCD

Tool for JTAG programming.
 

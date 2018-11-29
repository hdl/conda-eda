# conda-hdmi2usb-packages

Conda build recipes for HDMI2USB-litex-firmware build dependencies.

Basically, anything which hasn't gotten a proper package at https://launchpad.net/~timvideos/+archive/ubuntu/hdmi2usb

# Toolchains

## LiteX "soft-CPU" support

The LiteX system supports both a `lm32` and `or1k` "soft-CPU" implementations.

Current versions are;

 * binutils - 2.31.0
 * gcc - 8.2.0
 * gcc+newlib - 8.2.0 + 3.0.0
 * gdb - 8.2

### lm32-elf

 * All come from upstream.

### or1k-elf

 * binutils, gdb & newlib - upstream
 * gcc - Rebase of Stafford Horn's gcc 9.0 patches

## riscv32-elf

 * All come from upstream.

## Cypress FX2 support

 * sdcc (Current version: 3.5.0)

# Support Tools

## OpenOCD

Tool for JTAG programming.


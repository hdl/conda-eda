# conda-hdmi2usb-packages

Conda build recipes for HDMI2USB-misoc-firmware build dependencies.

Basically, anything which hasn't gotten a proper package at https://launchpad.net/~timvideos/+archive/ubuntu/hdmi2usb

# Toolchains

## MiSoC "soft-CPU" support

The MiSoC system supports both a `lm32` and `or1k` "soft-CPU" implementations.

### lm32-elf

"Bare metal" cross compiler.

 - binutils - Upstream 2.26.0
 - gcc - Upstream 4.9.3
 - gdb - Upstream 7.11

### or1k-elf

"Bare metal" cross compiler.

 - binutils - Upstream 2.26.0
 - gcc - or1k fork, based on upstream 4.9.3
 - gdb - or1k fork, based on upstream 7.11

## Cypress FX2 support

 * sdcc (Current version: 3.5.0)

# Support Tools

## OpenOCD

Tool for JTAG programming.
 

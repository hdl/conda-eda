# conda-hdmi2usb-packages

Conda build recipes for HDMI2USB-misoc-firmware build dependencies.

Basically, anything which hasn't gotten a proper package at https://launchpad.net/~timvideos/+archive/ubuntu/hdmi2usb

# Toolchains

## MiSoC "soft-CPU" support

The MiSoC system supports both a `lm32` and `or1k` "soft-CPU" implementations.

### lm32-elf

"Bare metal" cross compiler.

 - binutils - (Current version: 2.25.1)
 * gcc - (Current version: 4.9.3)

### or1k-elf

*In progress*

"Bare metal" cross compiler.

 - [ ] binutils - (Based off 2.24)
 - [ ] gcc - ???

Following instructions at http://openrisc.io/newlib/building.html

## Cypress FX2 support

 * sdcc (Current version: 3.5.0)

# Support Tools

## OpenOCD

Tool for JTAG programming.
 

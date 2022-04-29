# Module spi_w25q_read_32b()
Read 32-bits from serial flash memory IC (W25Qxxx) using standard SPI mode (SCK, /CS, SDI, SDO).
Can be used in "FemtoRV" (a minimalistic RISC-V CPU), or to read data in the "iCESugar-nano" FPGA development board.

## Build test bench on hardware
```
% make clean && make build
% icesprog build/top.bin
```

## Build test bench simulation
```
% make clean && make verify
% gtkwave build_sim/icesnano_spi_tb.vcd
```

## Lint the module
```
% make lint
```

## Read bytes from the flash IC
```
% icesprog -r -o 0x00020000 -l 4 ; echo "" ; hexdump 4 ; rm 4
```

## Misc notes

- The `-s` in `icepack -s` is to wake-up the flash IC from sleeping after FPGA bitstream load, very important.
- The IC W25Qxxx need a delay of `tRES1=3uS` (in W25Qxxx datasheet) after waking up from power-down command to be functional.
- For IC W25Qxxx, `spi_sck` max frequency is **50MHz** in standard SPI mode.

## Test hardware
- iCE40LP1KCM36 FPGA (iCESugar-nano FPGA development board).

## Statistics
Building report for `spi_w25q_read_32b()` in a test bench (`top.v`):

```
Info: Device utilisation:
Info: 	         ICESTORM_LC:    89/ 1280     6%
Info: 	        ICESTORM_RAM:     0/   16     0%
Info: 	               SB_IO:    10/  112     8%
Info: 	               SB_GB:     3/    8    37%
Info: 	        ICESTORM_PLL:     0/    1     0%
Info: 	         SB_WARMBOOT:     0/    1     0%

Total number of logic levels: 24
Total path delay: 7.48 ns (133.68 MHz)
```

---
# Copyright

Copyright Abderraouf Adjal 2022.

This source describes Open Hardware and is licensed under the CERN-OHL-P v2 or later

You may redistribute and modify this documentation and make products using it under the terms of the CERN-OHL-P v2 (https:/cern.ch/cern-ohl).
This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-P v2 for applicable conditions.


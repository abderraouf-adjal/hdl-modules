`timescale 10ns/1ns // time-unit/precision

/**
 * Copyright Abderraouf Adjal 2022.
 * 
 * This source describes Open Hardware and is licensed under the CERN-OHL-P v2 or later
 * 
 * You may redistribute and modify this documentation and make products using
 * it under the terms of the CERN-OHL-P v2 (https:/cern.ch/cern-ohl).
 * This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
 * INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
 * PARTICULAR PURPOSE. Please see the CERN-OHL-P v2 for applicable conditions.
 */

/**
 * Read 32-bits from flash memory IC (W25Qxxx) using standard SPI mode (SCK, /CS, SDI, SDO).
 * NOTE: The IC W25Qxxx need a delay of "tRES1=3uS" after waking up from power-down command to be functional.
 * NOTE: For IC W25Qxxx, spi_sck max frequency is 50MHz in standard SPI mode.
 *
 * Module spi_w25q_read_32b() is licensed under CERN-OHL-P v2 or later
 */
module spi_w25q_read_32b (
    // :: Global control
    input wire clk, // global clock, rising edge
    input wire start, // trigger operation
    
    // :: Commands data input
    input wire [23:0] mem_addr, // Address of the word in memory, 24-bit (up to 128M bit / 16 MiB)
    
    // :: Result and status
    output wire [31:0] mem_data, // word(s) data buffer
    output wire busy, // If the module is busy (data output is not ready)

    // :: Standard SPI pins to the flash memory IC W25Qxxx
    output wire spi_sck,  // SPI clock
    output wire spi_cs_n, // SPI chip select, low-active
    output wire spi_copi, // a.k.a SPI MOSI, Tx to the memory IC (controller out / peripheral in)
    input  wire spi_cipo  // a.k.a SPI MISO, Rx from memory IC (controller in / peripheral out)
);

    localparam IC_CMD = 8'h03; // The command to read in standard SPI mode.
    localparam SPI_COPI_IDLE = 1'b0; // Better to be 1'bZ, if the tools can do it.
    
    // :: Status
    reg [31:0] shiftr;
    reg [6:0] clk_cnt;
    
    // in mem_data, swap bytes order of `shiftr` since the we read lower address first.
    assign mem_data = {shiftr[7:0], shiftr[15:8], shiftr[23:16], shiftr[31:24]};
    assign busy = !spi_cs_n;
    assign spi_cs_n = clk_cnt[6] && !start; // = !(!clk_cnt[6] || start);
    assign spi_sck = !(clk || clk_cnt[6] || start); // = !clk && !clk_cnt[6] && !start;
    assign spi_copi = (clk_cnt[6] || clk_cnt[5]) ? SPI_COPI_IDLE : shiftr[31];
    
    
    // :: Init
    initial begin
        clk_cnt[6] = 1'b1;
    end

    always @(posedge clk) begin
        if (start) begin
            shiftr <= {IC_CMD[7:0], mem_addr[23:0]};
            clk_cnt <= 7'd0;
        end else if (!clk_cnt[6]) begin
            shiftr <= {shiftr[30:0], spi_cipo};
            clk_cnt <= clk_cnt + 7'd1;
        end
    end

endmodule


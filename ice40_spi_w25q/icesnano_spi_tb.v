// Testbench for icesnano_spi.v
`include "spi_w25q_read_32b.v"

`timescale 10ns/1ns // time-unit/precision

module icesnano_spi_tb;
    // global control
    reg clk; // global clock, rising edge
    
    reg start; // trigger operation
    // data input
    reg [23:0] mem_addr;
    wire busy;
    // result and status
    wire [31:0] mem_data;
    // :: Standard SPI pins to the flash memory IC W25Qxxx
    wire spi_sck;  // SPI clock
    wire  spi_cs_n; // SPI chip select, low-active
    wire spi_copi; // a.k.a SPI MOSI, Tx to the memory IC (controller out / peripheral in)
    reg spi_cipo;  // a.k.a SPI MISO, Rx from memory IC (controller in / peripheral out)

    // duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
    localparam period = 1;
    integer i;
    reg didexec;
    reg indc;

    spi_w25q_read_32b UUT(.clk(clk), .start(start),
        .mem_addr(mem_addr), .mem_data(mem_data), .busy(busy),
        .spi_sck(spi_sck), .spi_cs_n(spi_cs_n), .spi_copi(spi_copi), .spi_cipo(spi_cipo));
    
    always #1 clk = (clk === 1'b0);
    
    initial
    begin
        $dumpfile("icesnano_spi_tb.vcd"); // Dump for GTKWave tool
        $dumpvars(0, icesnano_spi_tb);
        spi_cipo = 1'bZ;
        mem_addr = 24'h10000;
        start = 1'b0;
        didexec = 1'b0;
        indc = 1'b0;
        i=0;
    end
    
    always @(posedge clk) begin
        if (i > 31 && i <= 64) begin
	            spi_cipo = 1'b1;
	        end else begin
	            spi_cipo = 1'bZ;
	        end
        if (i == 70) begin
            $finish;
        end else begin
            i=i+1;
        end
        
        if (!start && !busy && !didexec) begin
            start <= 1'b1;
            didexec <= 1'b1;
        end else if (start && busy) begin
            start <= 1'b0;
        end
        
        if (!busy && didexec && (mem_data == 32'hFFFFFFFF)) begin
            indc <= 1'b1;
        end
    end

endmodule


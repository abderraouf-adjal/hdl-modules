
`include "spi_w25q_read_32b.v"

// Tested in iCE40LP1K
// NOTE: The IC W25Qxxx need a delay of "tRES1=3uS" after waking up from power-down command to be functional.
// NOTE: For IC W25Qxxx, spi_sck max frequency is 50MHz in standard SPI mode.
module top(input wire CLK, output wire LED,
	// :: Standard SPI pins to the flash memory IC W25Qxxx
    output wire SPI_CLK,  // SPI clock
    output wire SPI_CS_N, // SPI chip select, low-active
    output wire SPI_COPI, // a.k.a SPI MOSI, Tx to the memory IC (controller out / peripheral in)
    input wire SPI_CIPO, // a.k.a SPI MISO, Rx from memory IC (controller in / peripheral out)
    
    // :: Standard SPI pins to test using a logic analyzer
    output wire DSPI_CLK,  // SPI clock
    output wire DSPI_CS_N, // SPI chip select, low-active
    output wire DSPI_COPI, // a.k.a SPI MOSI, Tx to the memory IC (controller out / peripheral in)
    output wire DSPI_CIPO // a.k.a SPI MISO, Rx from memory IC (controller in / peripheral out)
);

    // NOTE: Test data, read the chip content from external tool, and put the data here,
    // the LED will be on if the data match
    localparam TEST_ADDR = 24'h010000; localparam TEST_DATA = 32'h464c457f;
    //localparam TEST_ADDR = 24'h020000; localparam TEST_DATA = 32'hffffffff;
    
    // global control
    reg start; // trigger operation
    // data input
    reg [23:0] mem_addr;
    wire busy;
    // result and status
    reg [31:0] mem_data;
    
    reg indc;
    reg didexec;
    
    reg [25:0] timer_counter;
    
    assign LED = indc;
    
    assign DSPI_CLK = SPI_CLK;
    assign DSPI_CS_N = SPI_CS_N;
    assign DSPI_COPI = SPI_COPI;
    assign DSPI_CIPO = SPI_CIPO;
    
    spi_w25q_read_32b spi_flash_ctrl(.clk(CLK), .start(start),
        .mem_addr(mem_addr), .mem_data(mem_data), .busy(busy),
        .spi_sck(SPI_CLK), .spi_cs_n(SPI_CS_N), .spi_copi(SPI_COPI), .spi_cipo(SPI_CIPO));
    
    initial begin
        mem_addr = TEST_ADDR;
        start = 1'b0;
        indc = 1'b0;
        timer_counter = 0;
        didexec = 0;
    end
    
    always @(posedge CLK) begin
        if (!timer_counter[24]) begin
            if (!start && !busy && !didexec) begin
                start <= 1'b1;
                didexec <= 1;
            end else if (start && busy) begin
                start <= 1'b0;
            end
        end else begin
            didexec <= 0;
        end
        
        indc <= (!busy && (mem_data == TEST_DATA)) ? 1'b1 : 1'b0;
        timer_counter <= timer_counter + 1;
    end

endmodule


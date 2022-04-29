top_file = top
testbench_top_file = simulation_tb
pcf_file = io_icesugar_nano.pcf
build_dir = build
sim_dir = build_sim

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}

# NOTE: The "-s" in "icepack -s" is to wake-up the flash IC from sleeping after FPGA bitstream load, very important.
# NOTE: The IC W25Qxxx need a delay of "tRES1=3uS" after waking up from power-down command to be functional.
# NOTE: For IC W25Qxxx, spi_sck max frequency is 50MHz in standard SPI mode.

build:
	mkdir -p $(build_dir)
	yosys -q -p "synth_ice40 -abc2 -relut -json $(build_dir)/$(top_file).json -blif $(build_dir)/$(top_file).blif -top $(top_file)" $(top_file).v
	nextpnr-ice40 --lp1k --package cm36 --freq 50 --json $(build_dir)/$(top_file).json --pcf $(pcf_file) --asc $(build_dir)/$(top_file).asc
	icetime -d lp1k -P cm36 -p $(pcf_file) -t $(build_dir)/$(top_file).asc
	icepack -s $(build_dir)/$(top_file).asc $(build_dir)/$(top_file).bin

verify:
	mkdir -p $(sim_dir)
	iverilog -g2005 -Wall -Winfloop -Wfloating-nets -s $(testbench_top_file) -o $(sim_dir)/$(testbench_top_file).vvp $(testbench_top_file).v
	(cd $(sim_dir) && vvp $(testbench_top_file).vvp)
	
lint:
	verilator --lint-only  -Wall --top-module $(top_file) $(top_file).v

clean:
	rm -rf $(build_dir) $(sim_dir)

prog_flash_icelink:
	@if [ -d '$(ICELINK_DIR)' ]; \
        then \
            cp $(build_dir)/$(top_file).bin $(ICELINK_DIR); \
        else \
            echo "iCELink not found"; \
            exit 1; \
    fi


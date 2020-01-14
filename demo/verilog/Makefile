PCF=hx8k-bo-board.pcf

#IVERILOG=iverilog
#VVP=vvp
#YOSYS=yosys
#ICEPACK=icepack
#ARACHNE=arachne-pnr
NEXTPNR=nextpnr-ice40

TOOLS_PREFIX=$(HOME)/devel/hdl-learning/bin
IVERILOG=$(TOOLS_PREFIX)/bin/iverilog
VVP=$(TOOLS_PREFIX)/bin/vvp
YOSYS=$(TOOLS_PREFIX)/bin/yosys
ICEPACK=$(TOOLS_PREFIX)/bin/icepack
ICEPROG=$(TOOLS_PREFIX)/bin/iceprog

NEXTPNR=$(TOOLS_PREFIX)/bin/nextpnr-ice40
NEXTPNR_FLAGS=--hx8k --package ct256

ARACHNE_FLAGS="-d 8k -P ct256"

#SIM_OBJECT = rxuart2
#SIM_OBJECT = uart_test
#FPGA_OBJECT = io_mcp23017
#FPGA_OBJECT = i2c_tx
FPGA_OBJECT= simple-logic
#FPGA_OBJECT= sram_fifo
#FPGA_OBJECT = pincontrol
#FPGA_OBJECT = 8leds_4094be
#FPGA_OBJECT = 16leds_mcp23017

SIM_OBJECT = $(FPGA_OBJECT)

TOP_OBJECT = top

BAUDRATE = 115200
#BAUDRATE = 230400
#BAUDRATE = 460800
#BAUDRATE = 921600
#BAUDRATE = 1000000
#BAUDRATE = 3000000
#BAUDRATE = 4000000

all: $(notdir $(CURDIR)).bin

%.vvp: %.v
	$(IVERILOG) -grelative-include -g2005-sv -o $@ $<

%.vcd: %.vvp
	$(VVP) $<
	touch $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.asc: %.nljson
	$(NEXTPNR) $(NEXTPNR_FLAGS) --asc $@ --pcf $(PCF) --pcf-allow-unconstrained --write $*.place.nljson --json $<

guisyn: $(FPGA_OBJECT).asc
	$(NEXTPNR) $(NEXTPNR_FLAGS) --json $(FPGA_OBJECT).place.nljson --pcf $(PCF) --pcf-allow-unconstrained --gui

%.nljson: %.v
	$(YOSYS) -f verilog -p 'synth_ice40 -top $(TOP_OBJECT)' -b json -o $@ $<

upload: $(FPGA_OBJECT).bin
	$(ICEPROG) -S $<

sim: $(SIM_OBJECT)_tb.vcd
	gtkwave $< $(SIM_OBJECT)_tb.gtkw

tsim: $(SIM_OBJECT)_tb.vcd

# sets up tty
tty:
	stty -F /dev/ttyUSB1 cs8 -hup -parenb -cstopb -clocal -echo raw speed $(BAUDRATE)

clean:
	rm -f *.bin *.txt *.blif *.rpt *.vvp *.vcd *.nljson *.asc

.PRECIOUS: %.bin %.asc %.nljson 
.PHONY: all explain install clean simclean sim tty

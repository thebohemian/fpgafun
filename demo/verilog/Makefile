# Makefile that works for hx8k breakout board and radiona ulx3s

TOOLS_PREFIX=$(HOME)/devel/hdl-learning/install-root/bin

ifeq ($(DEVICE),hx8k)
	BOARD=hx8k
	PCF=hx8k-bo-board.pcf
	YOSYS_FLAGS=-DBOARD=$(BOARD) -f verilog -p 'synth_ice40 -top $(TOP_OBJECT)'
	NEXTPNR_FLAGS=--hx8k --package ct256 --pcf $(PCF) --pcf-allow-unconstrained
	NEXTPNR_SUFFIX=ice40
	PACK=$(TOOLS_PREFIX)/icepack
	PACK_FLAGS=
	PROG=$(TOOLS_PREFIX)/iceprog
	PROG_FLAGS=-S
	BITSTREAM=$(FPGA_OBJECT).bin
else
	BOARD=ulx3s
	# so far names used in verilog follow the hx8k bo board, so aliases have been added
	LPF=ulx3s_v20.lpf
	YOSYS_FLAGS=-DBOARD=$(BOARD) -f verilog -p 'synth_ecp5 -top $(TOP_OBJECT)'
	NEXTPNR_FLAGS=--lpf $(LPF) --85k --package CABGA381
	NEXTPNR_SUFFIX=ecp5
	PACK=$(TOOLS_PREFIX)/ecppack
	PACK_FLAGS=
	PROG=$(TOOLS_PREFIX)/fujprog
	PROG_FLAGS=
	BITSTREAM=$(FPGA_OBJECT).bit
endif

IVERILOG=$(TOOLS_PREFIX)/iverilog
VVP=$(TOOLS_PREFIX)/vvp
YOSYS=$(TOOLS_PREFIX)/yosys
NEXTPNR=$(TOOLS_PREFIX)/nextpnr-$(NEXTPNR_SUFFIX)

SIM_OBJECT = $(FPGA_OBJECT)
TOP_OBJECT = top

#SIM_OBJECT = rxuart2
#SIM_OBJECT = uart_test

#FPGA_OBJECT = blink
#FPGA_OBJECT = blink2
FPGA_OBJECT = blink_30
#FPGA_OBJECT = io_mcp23017
#FPGA_OBJECT = i2c_tx
#FPGA_OBJECT= simple-logic
#FPGA_OBJECT= sram_fifo
#FPGA_OBJECT = pincontrol
#FPGA_OBJECT = 8leds_4094be
#FPGA_OBJECT = 16leds_mcp23017


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

guisyn: $(FPGA_OBJECT).asc
	$(NEXTPNR) $(NEXTPNR_FLAGS) --json $(FPGA_OBJECT).place.nljson --pcf $(PCF) --pcf-allow-unconstrained --gui

ifeq ($(DEVICE),hx8k)

%.bin: %.asc
	$(PACK) $(PACK_FLAGS) $< $@

%.asc: %.nljson
	$(NEXTPNR) $(NEXTPNR_FLAGS) --asc $@ --write $*.place.nljson --json $<
else

%.config: %.nljson $(LPF) 
	$(NEXTPNR) $(NEXTPNR_FLAGS) --json $< --lpf $(LPF) --textcfg $@

%.bit: %.config
	$(PACK) $< $@ --compress

endif

%.nljson: %.v
	$(YOSYS) $(YOSYS_FLAGS) -b json -o $@ $<

upload: $(BITSTREAM)
	$(PROG) $(PROG_FLAGS) $<

sim: $(SIM_OBJECT)_tb.vcd
	gtkwave $< $(SIM_OBJECT)_tb.gtkw

tsim: $(SIM_OBJECT)_tb.vcd

# sets up tty
tty:
	stty -F /dev/ttyUSB1 cs8 -hup -parenb -cstopb -clocal -echo raw speed $(BAUDRATE)

clean:
	rm -f *.bin *.txt *.blif *.rpt *.vvp *.vcd *.nljson *.asc *.bit *.config

.PRECIOUS: %.bin %.asc %.nljson 
.PHONY: all explain install clean simclean sim tty

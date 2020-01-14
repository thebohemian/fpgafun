# self-compiled tools home
TOOLS_PREFIX=$(HOME)/devel/hdl-learning/bin

IVERILOG=$(TOOLS_PREFIX)/bin/iverilog
IVERILOG_FLAGS=-g2005-sv
VVP=$(TOOLS_PREFIX)/bin/vvp
YOSYS=$(TOOLS_PREFIX)/bin/yosys
ICEPACK=$(TOOLS_PREFIX)/bin/icepack
ICEPROG=$(TOOLS_PREFIX)/bin/iceprog
NEXTPNR=$(TOOLS_PREFIX)/bin/nextpnr-ice40

# flags set up for hx8k-ct256 variant
NEXTPNR_FLAGS=--hx8k --package ct256 --force 
ARACHNE_FLAGS="-d 8k -P ct256"
PCF=hx8k-ct256.pcf

SIM_OBJECT = gameboyboard1
FPGA_OBJECT = $(SIM_OBJECT)
TOP_OBJECT = top

BAUDRATE = 3000000

# send raw bytes (in hex) through UART:
# printf '\x18\x01\x00\x00\x01\x20\x05\x80\x06\xf5\x04\x21' > /dev/ttyUSB1 

all: $(notdir $(CURDIR)).bin

%.vvp: %.v
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $<

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

aplay: $(SIM_OBJECT)_tb.vcd
	ffmpeg -f s16le -ar 8000 -ac 1 -i audio.pcm audio.wav
	aplay audio.wav

simclean:
	rm -f *.vvp *.vcd *.wav

clean:
	rm -f *.bin *.asc *.rpt *.vvp *.vcd *.nljson *.pcm

# sets up tty
tty:
	stty -F /dev/ttyUSB1 cs8 -hup -parenb -cstopb -clocal -echo raw speed $(BAUDRATE)

.PRECIOUS: %.bin %.asc %.nljson 
.PHONY: all explain install clean simclean sim tty

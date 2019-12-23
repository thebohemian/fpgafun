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

OBJECT = blink2

all: $(notdir $(CURDIR)).bin

%.vvp: %.v
	$(IVERILOG) -o $@ $<

%.vcd: %.vvp
	$(VVP) $<
	touch $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.asc: %.json
	$(NEXTPNR) $(NEXTPNR_FLAGS) --asc $@ --pcf $(PCF) --pcf-allow-unconstrained --write $*.place.json --json $<

%.json: %.v
	$(YOSYS) -f verilog -p 'synth_ice40 -top main' -b json -o $@ $<

upload: $(OBJECT).bin
	$(ICEPROG) -S $<

inspect: $(OBJECT)_tb.vcd
	gtkwave $< $(OBJECT)_tb.gtkw

clean:
	rm -f *.bin *.txt *.blif *.rpt *.vvp *.vcd

.PRECIOUS: %.bin %.txt %.blif 
.PHONY: all explain install clean inspect

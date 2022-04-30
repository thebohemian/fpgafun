PCF=hx8k-bo-board.pcf
OBJECT = blink
VHDL_OBJECTS = blink.o blink_tb.o
SIM_FLAGS=--stop-time=500ms

#IVERILOG=iverilog
#VVP=vvp
#YOSYS=yosys
#ICEPACK=icepack
#NEXTPNR=nextpnr-ice40

TOOLS_PREFIX=$(HOME)/devel/hdl-learning/install-root/bin
IVERILOG=$(TOOLS_PREFIX)/iverilog
VVP=$(TOOLS_PREFIX)/vvp

GHDL=$(TOOLS_PREFIX)/ghdl
GHDL_FLAGS=--std=08

YOSYS=$(TOOLS_PREFIX)/yosys
YOSYS_VHDL_FLAGS=-m ghdl -p 'ghdl $(VHDL_SOURCES) -e $(OBJECT); synth_ice40' -b json
ICEPACK=$(TOOLS_PREFIX)/icepack

NEXTPNR=$(TOOLS_PREFIX)/nextpnr-ice40
NEXTPNR_FLAGS=--hx8k --package ct256

all: $(notdir $(CURDIR)).bin

$(OBJECT)_tb: $(VHDL_OBJECTS)
	$(GHDL) -e $(GHDL_FLAGS) $@

%.o: %.vhd
	$(GHDL) -a $(GHDL_FLAGS) $<
        
%.vvp: %.v
	$(IVERILOG) -o $@ $<

%.fst: %
	./$< $(SIM_FLAGS) --fst=$@
	
#%.vcd: %.vvp
#	$(VVP) $<
#	touch $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.asc: %.json
	$(NEXTPNR) $(NEXTPNR_FLAGS) --asc $@ --pcf $(PCF) --pcf-allow-unconstrained --write $*.place.json --json $<

%.json: %.vhd
	$(YOSYS) $(YOSYS_VHDL_FLAGS) -o $@

upload: $(OBJECT).bin iceprog $<

fst: $(OBJECT)_tb.fst
	gtkwave $< $(OBJECT)_tb.gtkw

vcd: $(OBJECT)_tb.vcd
	gtkwave $< $(OBJECT)_tb.gtkw

clean:
	rm -f $(OBJECT)_tb *.o *.bin *.txt *.blif *.rpt *.vvp *.vcd *.cf *.fst *.fst.hier

.PRECIOUS: %.bin %.txt %.blif 
.PHONY: all install clean fst vcd

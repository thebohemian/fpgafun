#IVERILOG=iverilog
#VVP=vvp
#YOSYS=yosys
#ICEPACK=icepack
#ARACHNE=arachne-pnr
#NEXTPNR=nextpnr-ice40

TOOLS_PREFIX=$(HOME)/devel/hdl-learning/bin
IVERILOG=$(TOOLS_PREFIX)/bin/iverilog
IVERILOG_FLAGS=-g2005-sv
VVP=$(TOOLS_PREFIX)/bin/vvp
YOSYS=$(TOOLS_PREFIX)/bin/yosys
ICEPACK=$(TOOLS_PREFIX)/bin/icepack
ICEPROG=$(TOOLS_PREFIX)/bin/iceprog
NEXTPNR=$(TOOLS_PREFIX)/bin/nextpnr-ice40

NEXTPNR_FLAGS=--hx8k --package ct256 --force 
ARACHNE_FLAGS="-d 8k -P ct256"

PCF=hx8k-ct256.pcf

SIM_OBJECT = dacboard3
FPGA_OBJECT = $(SIM_OBJECT)
TOP_OBJECT = $(SIM_OBJECT)

# Wandelt Quelle in einen PCM Stream mit
# - 1 Kanal
# - 8Bit Unsigned PCM
# - 11025 Hz Samplefrequenz um
# ffmpeg -i $(SONG) -ac 1 -f s16le -acodec pcm_s16le -ar 11025 song.raw

# spiele obigen Stream ab
# aplay -f s16le -c 1 -t raw -r 11025 song.raw

all: $(notdir $(CURDIR)).bin

%.vvp: %.v
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $<

%.vcd: %.vvp
	$(VVP) $<
	touch $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.asc: %.json
	$(NEXTPNR) $(NEXTPNR_FLAGS) --asc $@ --pcf $(PCF) --pcf-allow-unconstrained --write $*.place.json --json $<

%.json: %.v
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
	rm -f *.bin *.asc *.rpt *.vvp *.vcd *.json *.pcm

# sets up tty
# printf '\x18\x01\x00\x00\x01\x20\x05\x80\x06\xf5\x04\x21' > /dev/ttyUSB1 
tty:
#	stty -F /dev/ttyUSB1 cs8 -hup -parenb -cstopb -clocal -echo raw speed 150
	stty -F /dev/ttyUSB1 cs8 -hup -parenb -cstopb -clocal -echo raw speed 230400
#	stty -F /dev/ttyUSB1 cs8 -hup -parenb -cstopb -clocal -echo raw speed 115200

uart_bits: uart_bits.o

.PRECIOUS: %.bin %.asc %.json 
.PHONY: all explain install clean simclean sim

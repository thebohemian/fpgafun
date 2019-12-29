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

SIM_OBJECT = dacboard3
FPGA_OBJECT = $(SIM_OBJECT)
TOP_OBJECT = $(SIM_OBJECT)

#BAUDRATE = 150
#BAUDRATE = 115200
BAUDRATE = 230400
#BAUDRATE = 460800
#BAUDRATE = 921600

# Tool Examples:
# transforms source into PCM stream of:
# - 1 channel
# - 16bit signed PCM little-endian
# - 11025 Hz sample frequency
# ffmpeg -i $(SONG) -ac 1 -f s16le -acodec pcm_s16le -ar 11025 song.raw
#
# play stream:
# aplay -f s16le -c 1 -t raw -r 11025 song.raw
#
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

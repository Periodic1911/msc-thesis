TOP = top
OCD_CONFIG = /usr/share/icesugar-pro/tools/cmsisdap.cfg
PINS = pins.lpf
NPR_FLAGS = --25k --package CABGA256 --speed 6 --lpf $(PINS) --freq 65

all: $(TOP).bit

$(TOP).bit: $(TOP)_out.cfg
	ecppack --compress --svf $(TOP).svf $< $@

$(TOP)_flash.svf: $(TOP).bit
	/usr/share/icesugar-pro/tools/ujprog.bit2svf -j FLASH $< > $@

%.svf: %.bit
	

%_out.cfg: %.json
	nextpnr-ecp5 $(NPR_FLAGS) --json $< --textcfg $@

$(TOP).json: $(TOP).sv
	synlig -p "synth_ecp5 -json $@" $<

program_ram: $(TOP).svf
	sudo openocd -f $(OCD_CONFIG) -c "init; scan_chain; svf -tap ecp5.tap $< -quiet -progress; exit;"

program_flash: $(TOP)_flash.svf
	sudo openocd -f $(OCD_CONFIG) -c "init; scan_chain; svf -tap ecp5.tap $< -quiet -progress; exit;"

clean:
	rm -f *.svf *.json *.bit *_out.cfg

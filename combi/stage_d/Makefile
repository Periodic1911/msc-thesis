TOP = ldm
DEPS = stage_d.sv extend.sv regfile.sv stage_d.sv combi_decoder.sv ../common/common.sv combi_decoder_tb.sv ldm.sv ldm_tb.sv
OCD_CONFIG = /usr/share/icesugar-pro/tools/cmsisdap.cfg
PINS = pins.lpf
NPR_FLAGS = --25k --package CABGA256 --speed 6 --lpf $(PINS) --freq 65

all: $(TOP).bit

dump.vcd: $(TOP)_tb.sv $(DEPS)
	 verilator -j 8 -DRISCV --timescale 1ns --trace --binary --top-module $(TOP)_tb -I $^
	 ./obj_dir/V$(TOP)_tb

sim: dump.vcd
	gtkwave $<

%.svf: %.bit
	
%.stat: %.json
	synlig -p "stat" $^

%.svg: %.json
	netlistsvg -o $@ $<

svg: $(TOP).svg

%_out.cfg: %.json
	nextpnr-ecp5 $(NPR_FLAGS) --json $< --textcfg $@

%.json: $(DEPS)
	synlig -q -p "synth_ecp5 -json $@" -r $(@:.json=) $^

program_ram: $(TOP).svf
	sudo openocd -f $(OCD_CONFIG) -c "init; scan_chain; svf -tap ecp5.tap $< -quiet -progress; exit;"

program_flash: $(TOP)_flash.svf
	sudo openocd -f $(OCD_CONFIG) -c "init; scan_chain; svf -tap ecp5.tap $< -quiet -progress; exit;"

clean:
	rm -f *.svf *.json *.bit *_out.cfg

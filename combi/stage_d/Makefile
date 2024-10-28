TOP = stage_d
DEPS = stage_d.sv extend.sv regfile.sv stage_d.sv combi_decoder.sv
OCD_CONFIG = /usr/share/icesugar-pro/tools/cmsisdap.cfg
PINS = pins.lpf
NPR_FLAGS = --25k --package CABGA256 --speed 6 --lpf $(PINS) --freq 65

all: $(TOP).bit

dump.vcd: stage_m_tb.sv $(DEPS)
	 verilator -j 8 --timescale 1ns --trace --binary $(TOP)_tb.sv
	 ./obj_dir/V$(TOP)_tb

sim: dump.vcd
	gtkwave $<

%.svf: %.bit
	

%.svg: %.json
	netlistsvg -o $@ $<

svg: $(TOP).svg

%_out.cfg: %.json
	nextpnr-ecp5 $(NPR_FLAGS) --json $< --textcfg $@

$(TOP).json: $(TOP).sv $(DEPS)
	synlig -p "synth_ecp5 -json $@" -r $(TOP) $^

program_ram: $(TOP).svf
	sudo openocd -f $(OCD_CONFIG) -c "init; scan_chain; svf -tap ecp5.tap $< -quiet -progress; exit;"

program_flash: $(TOP)_flash.svf
	sudo openocd -f $(OCD_CONFIG) -c "init; scan_chain; svf -tap ecp5.tap $< -quiet -progress; exit;"

clean:
	rm -f *.svf *.json *.bit *_out.cfg

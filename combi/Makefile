TOP = combi
DEPS = common/common.sv combi.sv combi_tb.sv hazard/hazard.sv \
			 stage_d/combi_decoder.sv  stage_e/condlogic.sv   stage_f/top.sv \
       stage_d/extend.sv         stage_e/rvbranch.sv    stage_m/ram.sv \
       stage_d/regfile.sv        stage_e/stage_e.sv     stage_m/stage_m.sv \
       stage_d/stage_d.sv        stage_f/mem.sv         stage_w/stage_w.sv \
       stage_e/add_sub_tb.sv     stage_f/stage_f.sv \
       stage_e/alu.sv            stage_f/stage_f_tb.sv
OCD_CONFIG = /usr/share/icesugar-pro/tools/cmsisdap.cfg
PINS = pins.lpf
NPR_FLAGS = --25k --package CABGA256 --speed 6 --lpf $(PINS) --freq 65

all: $(TOP).bit

dump.vcd: $(TOP)_tb.sv $(DEPS)
	 verilator -j 8 --timescale 1ns --trace --binary --top-module $(TOP)_tb -I $^
	 ./obj_dir/V$(TOP)_tb

sim: dump.vcd
	gtkwave $<

%.svf: %.bit
	

%.svg: %.json
	netlistsvg -o $@ $<

%.stat: %.json
	synlig -p "stat" $^

svg: $(TOP).svg

%.bit: %_out.cfg
	ecppack --compress --svf $(@:.bit=.svf) $< $@

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

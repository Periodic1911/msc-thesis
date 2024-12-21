TOP = combi
DEPS = common/common.sv combi.sv combi_tb.sv hazard/hazard.sv \
			 stage_d/combi_decoder.sv  stage_e/condlogic.sv   stage_f/top.sv \
       stage_d/extend.sv         stage_e/rvbranch.sv    stage_m/ram.sv \
       stage_d/regfile.sv        stage_e/stage_e.sv     stage_m/stage_m.sv \
			 stage_m/memory.sv \
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

rv_tests/%.o: rv_tests/%.S rv_tests/riscv_test.h rv_tests/test_macros.h
	#riscv32-unknown-elf-as -march=rv32im -o $@ $<
	clang -c --target=riscv32 -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

%.hex: rv_tests/%.o
	riscv32-elf-ld -T rv.ld $< -o program.elf
	llvm-objcopy program.elf --output-target binary program.bin
	xxd -ps -c4 program.bin > program.hex.be
	cut -b 1-2 program.hex.be > program.hex.1
	cut -b 3-4 program.hex.be > program.hex.2
	cut -b 5-6 program.hex.be > program.hex.3
	cut -b 7-8 program.hex.be > program.hex.4
	paste program.hex.4 program.hex.3 program.hex.2 program.hex.1 | tr -d '\n\t' | fold -w 8 > $@
	cp $@ stage_f/program_rv.hex
	rm $@
	touch dump.vcd
	rm dump.vcd
	make dump.vcd > logs/$(basename $@).log
	mv dump.vcd dumps/$(basename $@).vcd
	grep 'RISCV Simulation succeeded' logs/$(basename $@).log

dass: program.elf
	llvm-objdump -d -M numeric $< | less

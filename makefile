# dir
dir_rtl 	= rtl/core
dir_sim 	= sim
dir_tb  	= tb
dir_code 	= code
dir_mem 	= rtl/soc/rom

# rtl
top_level 			= riscv32_cpu
top_level_tb 		= $(top_level)_tb
simulation_tb 		= $(dir_sim)/$(top_level_tb)
simulation_tb_vvp 	= $(simulation_tb).vvp
simulation_tb_vcd 	= $(simulation_tb).vcd

# code
code = assembly

ass_src = $(dir_code)/$(code).s
ass_obj = $(dir_code)/$(code).o
ass_elf = $(dir_code)/$(code).elf
ass_bin = $(dir_code)/$(code).bin
ass_hex = $(dir_mem)/memory_rom_init.hex

RISCV_AS 		= riscv32-unknown-elf-as
RISCV_GCC 		= riscv32-unknown-elf-gcc
RISCV_LD 		= riscv32-unknown-elf-ld
RISCV_OBJCOPY 	= riscv32-unknown-elf-objcopy
HEXDUMP 		= hexdump

vvp:
	iverilog -o $(simulation_tb_vvp) $(dir_tb)/$(top_level_tb).v

vcd:
	vvp $(simulation_tb_vvp) -o $(simulation_tb_vcd)

gtk:
	gtkwave -f $(simulation_tb_vcd)

$(ass_hex): $(ass_src)
	$(RISCV_AS) -march=rv64imcf_zca -o $(ass_obj) $<
	$(RISCV_LD) -o $(ass_elf) $(ass_obj)
	$(RISCV_OBJCOPY) -O binary $(ass_elf) $(ass_bin)
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $(ass_bin) > $@
	rm -f $(ass_obj) $(ass_elf) $(ass_bin)

ass: $(ass_hex)

all:
	iverilog -o $(simulation_tb_vvp) $(dir_tb)/$(top_level_tb).v
	vvp $(simulation_tb_vvp) -o $(simulation_tb_vcd)

complete: $(ass_hex)
	iverilog -o $(simulation_tb_vvp) $(dir_tb)/$(top_level_tb).v
	vvp $(simulation_tb_vvp) -o $(simulation_tb_vcd)

clean:
	rm -r sim/*.vvp sim/*.vcd
	rm -f $(dir_code)/code.o $(dir_code)/code.elf $(dir_code)/code.bin $(ass_hex)
	rm -f $(dir_code)/program.o $(dir_code)/program.elf $(dir_code)/program.bin $(c_hex)

# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
WAVES ?= 1

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

VERILOG_SOURCES = \
	src/common/*.sv \
	src/maths/mul.sv \
	src/neurons/neuron.sv \
	src/neurons/neuron_comb.sv \
	src/neurons/neuron_ram.sv \
	src/bram/*.sv \
	src/convolution/*.sv \
	examples/*.v \
	tb/simple_nn_tb.v

# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
#TOPLEVEL ?= simple_nn_tb
# MODULE is the basename of the Python test file
MODULE ?= test_simple_nn

ifeq ($(MODULE), test_neuron)
	TOPLEVEL = neuron_comb
else ifeq ($(MODULE), test_comb_nn)
    TOPLEVEL = comb_nn
else ifeq ($(MODULE), test_ram_nn)
    TOPLEVEL = ram_nn
else ifeq ($(MODULE), test_2d_conv)
    TOPLEVEL = convo_2d
else
	TOPLEVEL = simple_nn_tb
endif

#EXTRA_ARGS += -g2012

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += $(foreach v,$(filter PARAM_%,$(.VARIABLES)),-P $(TOPLEVEL).$(subst PARAM_,,$(v))=$($(v))) 

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump 
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += $(foreach v,$(filter PARAM_%,$(.VARIABLES)),-G$(subst PARAM_,,$(v))=$($(v)))

	ifeq ($(WAVES), 1)
		COMPILE_ARGS += --trace-fst
	endif
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	#echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	#echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst

# TOPLEVEL_LANG = verilog

# SIM ?= icarus
# WAVES ?= 0

# COCOTB_HDL_TIMEUNIT = 1ns
# COCOTB_HDL_TIMEPRECISION = 1ps

# DUT      = axis_adapter
# TOPLEVEL = $(DUT)
# MODULE   = test_$(DUT)
# VERILOG_SOURCES += ../../rtl/$(DUT).v

# # module parameters
# export PARAM_DATA_WIDTH := 8
# export PARAM_KEEP_WIDTH := $(shell expr \( $(PARAM_DATA_WIDTH) + 7 \) / 8 )
# export PARAM_STRB_WIDTH := $(shell expr \( $(PARAM_DATA_WIDTH) + 7 \) / 8 )
# export PARAM_S_COUNT := 1
# export PARAM_USER_WIDTH := 4
# export PARAM_RAM_ADDR_WIDTH := 1




# all: clean lint sim

# lint:	$(wildcard *.v)
# 	verible-verilog-lint --autofix inplace src/*.sv

# SRC_FILE=src/*.v
# INC_DIR= +incdir+=/src/*


testbench:
	iverilog -Wall -g2012 $(VERILOG_SOURCES) -o $@ 


# sim: clean testbench
# 	vvp ./testbench


clean_sim:
	rm -f testbench tb_layered tb_class *.vcd
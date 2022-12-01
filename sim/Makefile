PROJECT := tt02-fosfor-present
TOP_MODULE := fosfor_present_top
RTL_SRC := \
	../src/register.v \
	../src/present/s_box.v \
	../src/present/data_update.v \
	../src/present/key_update.v \
	../src/present/core_serial.v \
	../src/$(TOP_MODULE).v \
	
TB_SRC := $(TOP_MODULE)_tb.v
SRC := $(RTL_SRC) $(TB_SRC)

.PHONY: all
.PHONY: display
.PHONY: clean

all: display

$(PROJECT): $(SRC)
	@echo Compiling...
	iverilog -Wall -Wno-timescale -o $(PROJECT) $(SRC)

$(TOP_MODULE)_tb.vcd: $(PROJECT)
	@echo Simulating...
	./$(PROJECT)

display: $(TOP_MODULE)_tb.vcd $(TOP_MODULE)_tb.tcl
	@echo Displaying...
	gtkwave -f $(TOP_MODULE)_tb.vcd -S $(TOP_MODULE)_tb.tcl

clean:
	-rm -f $(PROJECT)
	-rm -f $(TOP_MODULE)_tb.vcd


# ============================================================================
# Cadence Xcelium - xrun Makefile
# Top module : dma_tb_hdl_top
# ============================================================================

# ----------------------------------------------------------------------------
# Tools
# ----------------------------------------------------------------------------
XRUN := xrun

# ----------------------------------------------------------------------------
# Directories
# ----------------------------------------------------------------------------
SIM_DIR   := $(abspath .)
PROJ_ROOT := $(abspath ..)
RTL_DIR   := $(PROJ_ROOT)/dut/rtl
INC_DIR   := $(RTL_DIR)/inc
CSR_DIR   := $(PROJ_ROOT)/dut/csr_out
PKG_DIR   := $(PROJ_ROOT)/dut/bus_arch_sv_pkg
RGGEN_DIR := $(PROJ_ROOT)/dut/rggen-verilog-rtl
TB_DIR    := $(PROJ_ROOT)/tb
LOG_DIR   := $(PROJ_ROOT)/logs

# ----------------------------------------------------------------------------
# Questa VIP (QVIP)
# ----------------------------------------------------------------------------
QUESTA_MVC_HOME ?= /ecad/apps2/mentor/questaVIP/v2026.1

QVIP_INCDIR := +incdir+$(QUESTA_MVC_HOME)/include \
               +incdir+$(QUESTA_MVC_HOME)/questa_mvc_src/sv \
               +incdir+$(QUESTA_MVC_HOME)/questa_mvc_src/sv/axi4 \
               +incdir+$(QUESTA_MVC_HOME)/questa_mvc_src/sv/axi4/modules

# QVIP SystemVerilog packages — compiled before TB sources
QVIP_SRC := $(QUESTA_MVC_HOME)/include/questa_mvc_svapi.sv \
            $(QUESTA_MVC_HOME)/questa_mvc_src/sv/mvc_pkg.sv \
            $(QUESTA_MVC_HOME)/questa_mvc_src/sv/axi4/mgc_axi4_v1_0_pkg.sv \
            $(QUESTA_MVC_HOME)/questa_mvc_src/sv/axi4/modules/axi4_slave.sv \
            $(QUESTA_MVC_HOME)/questa_mvc_src/sv/axi4/modules/axi4_master.sv

# QVIP shared library
QVIP_SV_ROOT := $(QUESTA_MVC_HOME)/questa_mvc_core/linux_x86_64_gcc-9.3_ius
QVIP_SV_LIB  := libaxi4_IN_SystemVerilog_IUS_full

TB_INC_DIR := +incdir+$(TB_DIR)

# ----------------------------------------------------------------------------
# Source files - ORDER IS IMPORTANT
# ----------------------------------------------------------------------------

# DUT packages
BUS_PKG_SRC := $(PKG_DIR)/amba_axi_pkg.sv
DMA_PKG_SRC := $(INC_DIR)/dma_utils_pkg.sv

# RTL sources
RTL_SRC := $(RTL_DIR)/dma_axi_if.sv \
           $(RTL_DIR)/dma_axi_wrapper.sv \
           $(RTL_DIR)/dma_fifo.sv \
           $(RTL_DIR)/dma_fsm.sv \
           $(RTL_DIR)/dma_func_wrapper.sv \
           $(RTL_DIR)/dma_streamer.sv \
           $(RTL_DIR)/intel_avalon_pkg.sv \
           $(RTL_DIR)/tb_axi_dma.sv

# rggen sources
RGGEN_SRC := $(sort $(wildcard $(RGGEN_DIR)/*.v))

# CSR block
CSR_SRC := $(CSR_DIR)/csr_dma.v

# Testbench sources
TB_SRC := $(TB_DIR)/dma_parameters_pkg.sv \
          $(TB_DIR)/dma_qvip_tb_params_pkg.sv \
          $(TB_DIR)/dma_typedef_pkg.sv \
          $(TB_DIR)/dma_uvc_pkg.sv \
          $(TB_DIR)/dma_interface.sv \
          $(TB_DIR)/dma_tb_hdl_top.sv 

# Full ordered source list
ALL_SRC := $(BUS_PKG_SRC) \
           $(RGGEN_SRC) \
           $(DMA_PKG_SRC) \
           $(CSR_SRC) \
           $(RTL_SRC) \
           $(TB_SRC)

# ----------------------------------------------------------------------------
# Top module
# ----------------------------------------------------------------------------
TOP := dma_tb_hdl_top

# ----------------------------------------------------------------------------
# UVM
# ----------------------------------------------------------------------------
UVM_HOME := /ecad/apps4/cadence/XCELIUMMAIN25.03.001/tools/methodology/UVM/CDNS-1.2

# ----------------------------------------------------------------------------
# Xcelium options
# ----------------------------------------------------------------------------
XRUN_OPTS := -64bit \
             -nocopyright \
             -access +rwc \
             -licqueue \
             -timescale 1ns/1ns \
             -uvm \
             -uvmhome $(UVM_HOME) \
             -nowarn CUVWSP \
             -nowarn DSEMEL \
             -nowarn DSEM2009 \
             -nowarn CLEAN \
             -nowarn SMFMAX \
             -nowarn RNDXCELON \
             -nowarn XCLGNOPTM 

# ----------------------------------------------------------------------------
# Include directories
# ----------------------------------------------------------------------------
INC_OPTS := +incdir+$(PROJ_ROOT)/dut \
            +incdir+$(RTL_DIR) \
            +incdir+$(INC_DIR) \
            +incdir+$(RGGEN_DIR) \
            +incdir+$(RGGEN_DIR)/rggen-sv-ral-master \
            +incdir+$(CSR_DIR) \
            $(QVIP_INCDIR) \
            $(TB_INC_DIR)

# ----------------------------------------------------------------------------
# Targets
# ----------------------------------------------------------------------------
.PHONY: all run gui clean help

all: run

run: | $(LOG_DIR)
	@echo "========================================================"
	@echo " Running Xcelium xrun with Questa AXI4 VIP"
	@echo " Top: $(TOP)"
	@echo "========================================================"
	env LD_LIBRARY_PATH=$(QVIP_SV_ROOT):$${LD_LIBRARY_PATH:-} \
	$(XRUN) $(XRUN_OPTS) $(INC_OPTS) \
	-sv_root $(QVIP_SV_ROOT) \
	-sv_lib $(QVIP_SV_LIB) \
	+define+MAP_PROT_ATTR \
	$(QVIP_SRC) \
	$(ALL_SRC) \
	+UVM_TESTNAME=dma_base_test \
	-top $(TOP) \
	-input probe.tcl \
	-log $(LOG_DIR)/xrun.log

gui: | $(LOG_DIR)
	@echo "========================================================"
	@echo " Running Xcelium GUI with Questa AXI4 VIP"
	@echo " Top: $(TOP)"
	@echo "========================================================"
	env LD_LIBRARY_PATH=$(QVIP_SV_ROOT):$${LD_LIBRARY_PATH:-} \
	$(XRUN) $(XRUN_OPTS) $(INC_OPTS) \
	-sv_root $(QVIP_SV_ROOT) \
	-sv_lib $(QVIP_SV_LIB) \
	+define+MAP_PROT_ATTR \
	$(QVIP_SRC) \
	$(ALL_SRC) \
	+UVM_TESTNAME=dma_base_test \
	-top $(TOP) \
	-input probe.tcl \
	-log $(LOG_DIR)/xrun_gui.log

$(LOG_DIR):
	mkdir -p $@

clean:
	@echo "Cleaning generated files..."
	rm -rf xcelium.d INCA_libs $(LOG_DIR)
	rm -f xrun.log xrun.history *.log *.diag .waves.shm xmsim.key

help:
	@echo ""
	@echo "Usage:"
	@echo "  make run     - Compile, elaborate, and run simulation"
	@echo "  make gui     - Open Xcelium GUI"
	@echo "  make clean   - Remove generated files"
	@echo ""
	@echo "Override options:"
	@echo "  TOP               - Top module name"
	@echo "  QUESTA_MVC_HOME   - Path to Questa MVC VIP installation"
	@echo ""

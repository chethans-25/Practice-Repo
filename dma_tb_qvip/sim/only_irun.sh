#!/bin/sh
 
xrun \
  -uvmhome CDNS-1.2 -64bit -sv -timescale 1ns/1ns -top dma_tb_hvl_top -top uvm_pkg \
  -top dma_tb_hdl_top \
  -incdir ../dut \
  -incdir ../dut/rtl \
  -incdir ../dut/bus_arch_sv_pkg \
  -incdir ../dut/rtl/inc \
  -incdir ../dut/rggen-verilog-rtl \
  -incdir ../dut/rggen-verilog-rtl/rggen-sv-ral-master \
  -incdir ../dut/csr_out \
  -incdir ../tb \
  ../dut/rtl/amba_ahb_pkg.sv \
  ../dut/bus_arch_sv_pkg/amba_axi_pkg.sv \
  ../dut/rtl/inc/dma_utils_pkg.sv \
  ../dut/rtl/inc/dma_pkg.svh \
  ../dut/rtl/dma_axi_if.sv \
  ../dut/rtl/dma_axi_wrapper.sv \
  ../dut/rtl/dma_fifo.sv \
  ../dut/rtl/dma_fsm.sv \
  ../dut/rtl/dma_func_wrapper.sv \
  ../dut/rtl/dma_streamer.sv \
  ../dut/rtl/intel_avalon_pkg.sv \
  ../dut/rtl/tb_axi_dma.sv \
  ../dut/rggen-verilog-rtl/rggen_adapter_common.v \
  ../dut/rggen-verilog-rtl/rggen_apb_bridge.v \
  ../dut/rggen-verilog-rtl/rggen_axi4lite_skid_buffer.v \
  ../dut/rggen-verilog-rtl/rggen_default_register.v \
  ../dut/rggen-verilog-rtl/rggen_mux.v \
  ../dut/rggen-verilog-rtl/rggen_rtl_macros.vh \
  ../dut/rggen-verilog-rtl/rggen_address_decoder.v \
  ../dut/rggen-verilog-rtl/rggen_axi4lite_adapter.v \
  ../dut/rggen-verilog-rtl/rggen_bit_field.v \
  ../dut/rggen-verilog-rtl/rggen_external_register.v \
  ../dut/rggen-verilog-rtl/rggen_or_reducer.v \
  ../dut/rggen-verilog-rtl/rggen_wishbone_adapter.v \
  ../dut/rggen-verilog-rtl/rggen_apb_adapter.v \
  ../dut/rggen-verilog-rtl/rggen_axi4lite_bridge.v \
  ../dut/rggen-verilog-rtl/rggen_bit_field_w01trg.v \
  ../dut/rggen-verilog-rtl/rggen_indirect_register.v \
  ../dut/rggen-verilog-rtl/rggen_register_common.v \
  ../dut/rggen-verilog-rtl/rggen_wishbone_bridge.v \
  ../dut/csr_out/csr_dma.v \
  ../tb/dma_parameters_pkg.sv \
  ../tb/dma_typedef_pkg.sv \
  ../tb/dma_interface.sv \
  ../tb/dma_uvc_pkg.sv \
  ../tb/dma_tb_hdl_top.sv \
  ../tb/dma_tb_hvl_top.sv \
  -access +rwc \
  -input probe.tcl

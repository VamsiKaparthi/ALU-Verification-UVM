//uvm
`include "uvm_macros.svh"
import uvm_pkg::*;

//parameters
parameter W = 8;
parameter SHIFT_WIDTH = $clog2(W);
parameter N = 2000;


//files
`include "seq_item.sv"
`include "seq.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "env.sv"
`include "test.sv"


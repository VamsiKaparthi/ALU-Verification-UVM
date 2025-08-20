// Code your testbench here
// or browse Examples
`include "define.svh"
`include "interface.sv"
`include "design.sv"
module top;
  bit clk, rst, ce;
  bit ERR;
  initial begin
    //ce = 1;
  	forever #5 clk = ~clk;
  end

  add_if vif(clk, rst, ce);

  ALU_DESIGN dut(.INP_VALID(vif.inp_valid), .OPA(vif.opa), .OPB(vif.opb), .CIN(vif.cin), .CLK(clk), .RST(rst), .CMD(vif.cmd), .CE(ce), .MODE(vif.mode), .COUT(vif.cout), .OFLOW(vif.oflow), .RES(vif.res), .G(vif.g), .E(vif.e), .L(vif.l), .ERR(vif.err));
  
  initial begin
    uvm_config_db#(virtual add_if)::set(null, "*", "vif", vif);
    uvm_config_db#(int)::set(null, "*", "ERR", ERR);
    run_test("regression_test");
    #10;
    $finish;
  end
  initial begin
    repeat(1)@(posedge clk);
    rst <= 1;
    
    @(posedge clk)
      rst <= 0;
    @(posedge clk)
	ce <= 1;  
  end
  initial begin
    clk = 0;
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule

`uvm_analysis_imp_decl(_mon_cg)
`uvm_analysis_imp_decl(_drv_cg)

class coverage extends uvm_component;
  `uvm_component_utils(coverage);
  uvm_analysis_imp_mon_cg#(seq_item, coverage) coverage_mon;
  uvm_analysis_imp_drv_cg#(seq_item, coverage) coverage_drv;
  seq_item pktd;
  seq_item pktm;
  covergroup drv_cg; //input functional coverage
    c1 : coverpoint pktd.opa {
      bins b1 = {[0:255]};
    }
    c2 : coverpoint pktd.opb{
      bins b1 = {[0:255]};
    }
    c3 : coverpoint pktd.cin;
    c4 : coverpoint pktd.mode;
    c5 : coverpoint pktd.inp_valid;
    c6 : coverpoint pktd.cmd;
    cross c6, c4;
    cross c5, c4;
    cross c6, c5;
  endgroup
  
  covergroup mon_cg; //output coverage
    c1 : coverpoint pktm.res{
      bins b1 = {0};
      bins b2 = {511};
      bins b3 = default;
    }
    c2 : coverpoint pktm.g{
      bins b1 = {1};
    }
    c3 : coverpoint pktm.l{
      bins b2 = {1};
    }
    c4 : coverpoint pktm.e{
      bins b3 = {1};
    }
    c5 : coverpoint pktm.oflow;
    c6 : coverpoint pktm.err;
    c7 : coverpoint pktm.cout;
  endgroup
  
  function new(string name = "coverage", uvm_component parent = null);
    super.new(name, parent);
    drv_cg = new;
    mon_cg = new;
    coverage_mon = new("coverage_mon", this);
    coverage_drv = new("coverage_drv", this);
  endfunction
  
  function void write_drv_cg(seq_item req);
    pktd = req;
    drv_cg.sample();
  endfunction
  
  function void write_mon_cg(seq_item req);
    pktm = req;
    mon_cg.sample();
  endfunction
  
endclass

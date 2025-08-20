class env extends uvm_env;
  `uvm_component_utils(env);
  agent agnt;
  scoreboard score;
  coverage fcov;
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt = agent::type_id::create("agnt", this);
    score = scoreboard::type_id::create("score", this);
    fcov = coverage::type_id::create("fcov", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agnt.mon.item_collect_mon.connect(score.item_collect_score);
    //agnt.drv.check_error.connect(score.error_collect_score);
    agnt.mon.item_collect_mon.connect(fcov.coverage_mon);
    agnt.mon.item_collect_drv.connect(fcov.coverage_drv);
  endfunction
endclass

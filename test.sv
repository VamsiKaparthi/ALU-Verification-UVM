class test extends uvm_test;
  `uvm_component_utils(test);
  env e1;
  seq sq;
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e1 = env::type_id::create("e1", this);
  endfunction
  task run_phase(uvm_phase phase);
    sq = seq::type_id::create("sq");
    phase.raise_objection(this);
    sq.start(e1.agnt.sqr);
    phase.drop_objection(this);
  endtask
endclass

class ls_test extends test;
  `uvm_component_utils(ls_test);
  seq_logical_single sq;
  function new(string name = "ls_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    sq = seq_logical_single::type_id::create("sq");
    phase.raise_objection(this);
    sq.start(e1.agnt.sqr);
    phase.drop_objection(this);
  endtask
endclass

class lt_test extends test;
  `uvm_component_utils(lt_test);
  seq_logical_two sq;
  function new(string name = "ls_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    sq = seq_logical_two::type_id::create("sq");
    phase.raise_objection(this);
    sq.start(e1.agnt.sqr);
    phase.drop_objection(this);
  endtask
endclass

class as_test extends test;
  `uvm_component_utils(as_test);
  seq_arithmetic_two sq;
  function new(string name = "as_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    sq = seq_arithmetic_two::type_id::create("sq");
    phase.raise_objection(this, "Raised");
    sq.start(e1.agnt.sqr);
    phase.drop_objection(this, "Dropped");
  endtask
endclass

class at_test extends test;
  `uvm_component_utils(at_test);
  seq_arithmetic_two sq;
  function new(string name = "at_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    sq = seq_arithmetic_two::type_id::create("sq");
    sq.start(e1.agnt.sqr);
  endtask
endclass

class regression_test extends test;
  `uvm_component_utils(regression_test);
  seq_regression sq;
  function new(string name = "regression_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    sq = seq_regression::type_id::create("sq");
    phase.raise_objection(this, "Raised");
    sq.start(e1.agnt.sqr);
    phase.drop_objection(this, "dropped");
  endtask
endclass

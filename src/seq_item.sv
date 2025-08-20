class seq_item extends uvm_sequence_item;
  //inputs
  rand bit [W-1:0] opa, opb;
  rand bit [3:0] cmd;
  rand bit mode, cin;
  rand bit [1:0] inp_valid;
  //constraint c1 {mode == 1; cmd == 9;}
  //constraint c2 {inp_valid == 0;}
  //outputs
  logic [W:0] res;
  logic oflow, cout, g, l, e, err;
  
  `uvm_object_utils_begin(seq_item)
  `uvm_field_int(opa, UVM_ALL_ON)
  `uvm_field_int(opb, UVM_ALL_ON)
  `uvm_field_int(cmd, UVM_ALL_ON)
  `uvm_field_int(mode, UVM_ALL_ON)
  `uvm_field_int(cin, UVM_ALL_ON)
  `uvm_field_int(inp_valid, UVM_ALL_ON)
  `uvm_field_int(res, UVM_ALL_ON)
  `uvm_field_int(oflow, UVM_ALL_ON)
  `uvm_field_int(cout, UVM_ALL_ON)
  `uvm_field_int(g, UVM_ALL_ON)
  `uvm_field_int(l, UVM_ALL_ON)
  `uvm_field_int(e, UVM_ALL_ON)
  `uvm_field_int(err, UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name = "seq_item");
    super.new(name);
  endfunction
endclass

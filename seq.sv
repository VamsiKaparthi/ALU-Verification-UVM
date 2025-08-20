class seq extends uvm_sequence#(seq_item);
  `uvm_object_utils(seq);
  function new(string name = "seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(N)begin
      req = seq_item::type_id::create();
      wait_for_grant();
      assert(req.randomize);
      $display("---------------------------------------------------------------------------------------------------------------------------");
      `uvm_info("REQ SEQ", $sformatf("opa = %0d, opb = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", req.opa, req.opb, req.cin, req.cmd, req.mode, req.inp_valid), UVM_NONE);
      send_request(req);
      wait_for_item_done();
      get_response(req);
    end
    
  endtask
endclass

class seq_logical_single extends uvm_sequence#(seq_item);
  `uvm_object_utils(seq_logical_single)
  function new(string name = "seq_ls");
    super.new(name);
  endfunction
  task body();
    repeat(N)begin
      `uvm_do_with(req, {req.mode == 0; req.cmd inside {6, 7, 8, 9, 10, 11};})
      get_response(req);
      $display("---------------------------------------------------------------------------------------------------------------------------");
    end
  endtask
endclass

class seq_logical_two extends uvm_sequence#(seq_item);
  `uvm_object_utils(seq_logical_two)
  function new(string name = "seq_lt");
    super.new(name);
  endfunction
  task body();
    repeat(N)begin
      `uvm_do_with(req, {req.mode == 0; req.cmd inside {0,1,2,3,4,5,6,12,13};})
      get_response(req);
      $display("---------------------------------------------------------------------------------------------------------------------------");
    end
  endtask
endclass

class seq_arithmetic_single extends uvm_sequence#(seq_item);
  `uvm_object_utils(seq_arithmetic_single)
  function new(string name = "seq_lt");
    super.new(name);
  endfunction
  task body();
    repeat(N)begin
      `uvm_do_with(req, {req.mode == 1; req.cmd inside {4, 5, 6, 7};})
      get_response(req);
      $display("---------------------------------------------------------------------------------------------------------------------------");
    end
  endtask
endclass

class seq_arithmetic_two extends uvm_sequence#(seq_item);
  `uvm_object_utils(seq_arithmetic_two)
  function new(string name = "seq_lt");
    super.new(name);
  endfunction
  task body();
    repeat(N)begin
      `uvm_do_with(req, {mode == 1; cmd inside {1,2,3,8,9,10};})
      get_response(req);
      $display("---------------------------------------------------------------------------------------------------------------------------");
    end
  endtask
endclass

class seq_regression extends uvm_sequence;
  `uvm_object_utils(seq_regression);
  seq sq;
  seq_logical_single ls_sq;
  seq_logical_two lt_sq;
  seq_arithmetic_single as_sq;
  seq_arithmetic_two at_sq;
  function new(string name = "seq_regression");
    super.new(name);
  endfunction
  task body();
    `uvm_do(sq);
    `uvm_do(ls_sq);
    `uvm_do(lt_sq);
    `uvm_do(as_sq);
    `uvm_do(at_sq);
  endtask
endclass

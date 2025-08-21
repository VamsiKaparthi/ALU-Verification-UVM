class driver extends uvm_driver#(seq_item);
  `uvm_component_utils(driver);
  virtual add_if vif;
  //uvm_analysis_port #(seq_item) item_collect_drv;
  //uvm_blocking_put_port #(int) check_error;
  
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
    //item_collect_drv = new("item_Collect_drv", this);
    //check_error = new("check_error", this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_if)::get(this, "", "vif", vif))
      `uvm_fatal("ERR", "Could not retrieve virtual interface in driver");
  endfunction
  
  task send();   
    `uvm_info("REQ DRV", $sformatf("opa = %0d, opb = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", req.opa, req.opb, req.cin, req.cmd, req.mode, req.inp_valid), UVM_NONE);
    vif.opa <= req.opa;
    vif.opb <= req.opb;
    vif.cin <= req.cin;
    vif.cmd <= req.cmd;
    vif.mode <= req.mode;
    vif.inp_valid <= req.inp_valid;
    //item_collect_drv.write(req);
  endtask
  
  task drive();
    bit flag = 0;
    //ERR = 0;
    //single operand commands
    int single_op_arithmetic[] = {4,5,6,7};
    int single_op_logical[] = {6,7,8,9,10,11};
    
    if(req.inp_valid == 3 || req.inp_valid == 0)begin
      send();
      repeat(1)@(vif.drv_cb);
      //send();
    end
    else if(req.mode == 1)begin : arithmetic_mode
      if(req.cmd inside {single_op_arithmetic})begin
        send();
        repeat(1)@(vif.drv_cb);
      end
      else begin : two_op_arithmetic
        send();
        req.cmd.rand_mode(0);
        req.mode.rand_mode(0);
        for(int i = 0; i < 16; i++)begin : for_loop
          repeat(1)@(vif.drv_cb);
          assert(req.randomize());
          send();
          `uvm_info("REQ DRV LOOP", $sformatf("opa = %0d, opb = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", req.opa, req.opb, req.cin, req.cmd, req.mode, req.inp_valid), UVM_NONE);
          if(req.inp_valid == 3)begin
            `uvm_info("DRV", $sformatf("count = %0d", i), UVM_LOW);
            flag = 1;
            repeat(1)@(vif.drv_cb);
      //      ERR = 0;
            break;
          end
        end : for_loop
        if(!flag)begin
        //  ERR = 1;
          @(vif.drv_cb);
        end
      end : two_op_arithmetic
    end : arithmetic_mode
    else begin : logical_mode
      if(req.cmd inside {single_op_logical})begin : single_op_logical
        send();
        repeat(1)@(vif.drv_cb);
      end : single_op_logical
      else begin : two_op_logical
        send();
        req.cmd.rand_mode(0);
        req.mode.rand_mode(0);
        for(int i = 0; i < 16; i++)begin : for_loop
          repeat(1)@(vif.drv_cb);
          assert(req.randomize());
          send();
          `uvm_info("REQ DRV LOOP", $sformatf("opa = %0d, opb = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", req.opa, req.opb, req.cin, req.cmd, req.mode, req.inp_valid), UVM_NONE);
          
          if(req.inp_valid == 3)begin
            `uvm_info("DRV", $sformatf("count = %0d", i), UVM_LOW);
            flag = 1;
            repeat(1)@(vif.drv_cb);
          //  ERR = 0;
            break;
          end
        end : for_loop
        if(!flag)begin
          uvm_config_db#(bit)::set(this, "*", "ERR", 1);
          //ERR = 1;
          @(vif.drv_cb);
        end
        else
          uvm_config_db#(bit)::set(this, "*", "ERR", 0);
      end : two_op_logical
    end
    
    repeat(2)@(vif.drv_cb);
    if(req.mode == 1 && (req.cmd == 9 || req.cmd == 10))begin
        repeat(1)@(vif.drv_cb); //multiplication
    end
  endtask
  
  task run_phase(uvm_phase phase);
    //repeat(1)@(vif.drv_cb);
    repeat(4)@(vif.drv_cb);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done(req);
    end
  endtask
endclass

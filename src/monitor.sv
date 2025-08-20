class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  virtual add_if vif;
  uvm_analysis_port #(seq_item) item_collect_mon;
  uvm_analysis_port #(seq_item) item_collect_drv;
  //uvm_analysis_port #(seq_item) coverage_monitor;
  seq_item mon_item;
  
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_item = new("mon_item");
    item_collect_mon = new("item_collect_mon", this);
    item_collect_drv = new("item_collect_drv", this);
  endfunction
  
  task recieve_inputs();
    `uvm_info("MON INPUTS", $sformatf("rst = %0d, opa = %0d, opb = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", vif.rst, vif.opa, vif.opb, vif.cin, vif.cmd, vif.mode, vif.inp_valid), UVM_NONE);
    mon_item.opa = vif.opa;
    mon_item.opb = vif.opb;
    mon_item.cmd = vif.cmd;
    mon_item.mode = vif.mode;
    mon_item.inp_valid = vif.inp_valid;
    mon_item.cin = vif.cin;
    item_collect_drv.write(mon_item);
  endtask
  
  task recieve_outputs();
    `uvm_info("MON OUTPUTS", $sformatf("res = %0d, err = %0d, cout = %0d, oflow = %0d, g = %0b, l = %0b, e = %0b", vif.res, vif.err, vif.cout, vif.oflow, vif.g, vif.l, vif.e), UVM_LOW);  	
    mon_item.res = vif.res;
    mon_item.cout = vif.cout;
    mon_item.err = vif.err;
    mon_item.oflow = vif.oflow;
    mon_item.g = vif.g;
    mon_item.l = vif.l;
    mon_item.e = vif.e;
  endtask
  
  task collect();
    bit flag = 0;
    int single_op_arithmetic[] = {4,5,6,7};
    int single_op_logical[] = {6,7,8,9,10,11};
    recieve_inputs();
    repeat(1)@(vif.mon_cb);
    if(mon_item.inp_valid == 3 || mon_item.inp_valid == 0)begin
      if(mon_item.mode == 1 && (mon_item.cmd == 9 || mon_item.cmd == 10))begin
       repeat(1)@(vif.mon_cb); //multiplication
      end      
    end
    else if(mon_item.mode == 1)begin : arithmetic_mode
      if(mon_item.cmd inside {single_op_arithmetic})begin
        
      end
      else begin : two_op_arithmetic
        for(int i = 0; i < 16; i++)begin : for_loop
          recieve_inputs();
          repeat(1)@(vif.mon_cb);
          if(mon_item.inp_valid == 3)begin
            `uvm_info("MON_LOOP_COUNT", $sformatf("count = %0d", i), UVM_LOW);
            if(mon_item.mode == 1 && (mon_item.cmd == 9 || mon_item.cmd == 10))begin
      		  repeat(1)@(vif.drv_cb); //multiplication
    		end
            flag = 1;
            break;
          end
        end : for_loop
        if(!flag)begin
          `uvm_info("MON LOOP", "ERROR LOOP TIMEOUT", UVM_NONE);
          if(mon_item.mode == 1 && (mon_item.cmd == 9 || mon_item.cmd == 10))begin
      		  repeat(1)@(vif.drv_cb); //multiplication
    		end
        end
        /*if(!flag)
          @(vif.mon_cb);*/
      end : two_op_arithmetic
    end : arithmetic_mode
    else begin : logical_mode
      if(mon_item.cmd inside {single_op_logical})begin : single_op_logical
        //send();
      end : single_op_logical
      else begin : two_op_logical
        for(int i = 0; i < 16; i++)begin : for_loop
          recieve_inputs();
          repeat(1)@(vif.mon_cb);
          if(mon_item.inp_valid == 3)begin
            `uvm_info("MON_LOOP_COUNT", $sformatf("count = %0d", i), UVM_LOW);
            flag = 1;
            break;
          end
        end : for_loop
        if(!flag)begin
          `uvm_info("MON LOOP", "ERROR LOOP TIMEOUT", UVM_NONE);
        end
      end : two_op_logical
    end
    recieve_outputs();
    //coverage_monitor.write_mon_cg(mon_item);
    item_collect_mon.write(mon_item);
    repeat(2)@(vif.mon_cb);
  endtask
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_if)::get(this, "", "vif", vif))
       `uvm_fatal("ERR","Could not retrieve retrieve virtual interface in monitor");
  endfunction
  
  task run_phase(uvm_phase phase);
    repeat(5)@(vif.mon_cb);
    repeat(N*5)begin
      collect();
    end
  endtask
endclass

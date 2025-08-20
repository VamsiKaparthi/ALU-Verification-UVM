class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);
  uvm_analysis_imp #(seq_item, scoreboard) item_collect_score;
  //uvm_blocking_put_imp #(int, scoreboard) error_collect_score;
  seq_item q[$];
  int e[$];
  seq_item scb_item, ref_scb_item;
  virtual add_if vif;
  int pass, fail;
  
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_collect_score = new("item_collect_score", this);
    //error_collect_score = new("error_collect_score", this);
    ref_scb_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_if)::get(this, "", "vif", vif))
      `uvm_fatal("SCORE ERR", "Cannot retrieve virtual interface");
  endfunction
  
  virtual function void write(seq_item pkt);
    q.push_back(pkt);
  endfunction
  
  virtual function void put(int err);
    e.push_back(err);
  endfunction
  
  task calculate(seq_item pkt, seq_item pkt2);
    `uvm_info("SCOREBOARD CALC", "Calculating", UVM_LOW);
    if(vif.rst)begin
      pkt2.res = 0;
      pkt2.oflow = 0;
      pkt2.cout = 0;
      pkt2.g = 0;
      pkt2.l = 0;
      pkt2.e = 0;
      pkt2.err = 0;
      $display("Enter Reset");
    end
    else if (vif.ce)begin
    //reseting the outputs
      pkt2.res = 9'bz;
      pkt2.oflow = 1'bz;
      pkt2.cout = 1'bz;
      pkt2.g = 1'bz;
      pkt2.l = 1'bz;
      pkt2.e = 1'bz;
      pkt2.err = 1'bz;
      if(pkt.mode == 1)begin //arithmetic
        case(pkt.inp_valid)
          2'b00:begin
            pkt2.err = 1;
          end
          2'b01:begin //only a valid
            case(pkt.cmd)
              4'b0100:begin //inc_a
                pkt2.res = pkt.opa + 1;
              end
              4'b0101:begin //dec_a
                pkt2.res = pkt.opa - 1;
              end
              default : pkt2.err = 1;
            endcase
          end
          2'b10:begin //only a valid
            case(pkt2.cmd)
              4'b0110:begin //inc_a
                pkt2.res = pkt.opb + 1;
              end
              4'b0111:begin //dec_a
                pkt2.res = pkt.opb - 1;
              end
              default : pkt2.err = 1;
            endcase
          end
          2'b11:begin
            case(pkt.cmd)
              4'b0000:begin //add
                pkt2.res = pkt.opa + pkt.opb;
                pkt2.cout = pkt.res[8];
              end
              4'b0001:begin //sub
                pkt2.res = pkt.opa - pkt.opb;
                pkt2.oflow = (pkt.opa < pkt.opb);
              end
              4'b0010:begin //add_cin
                pkt2.res = pkt.opa + pkt.opb + pkt.cin;
                pkt2.cout = pkt.res[8];
              end
              4'b0011:begin //sub_cin
                pkt2.res = pkt.opa - pkt.opb - pkt.cin;
                pkt2.oflow = ((pkt.opa <  pkt.opb + pkt.cin));
              end
              4'b0100:begin //inc_a
                pkt2.res = pkt.opa + 1;
                pkt2.cout = pkt.res[8];
              end
              4'b0101:begin //dec_a
                pkt2.res = pkt.opa - 1;
                pkt2.oflow = (pkt.opa < 1);
              end
              4'b0110:begin //inc_a
                pkt2.res = pkt.opb + 1;
              end
              4'b0111:begin //dec_a
                pkt2.res = pkt.opb - 1;
                pkt2.oflow = (pkt.opb < 1);
              end
              4'b1000:begin //cmp
                pkt2.g = (pkt.opa > pkt.opb) ? 1 : 1'bz;
                pkt2.l = (pkt.opa < pkt.opb) ? 1 : 1'bz;
                pkt2.e = (pkt.opa == pkt.opb) ? 1 : 1'bz;
              end
              4'b1001:begin //inc_mult
                pkt2.res = (pkt.opa + 1) * (pkt.opb + 1);
              end
              4'b1010:begin //shift_a_mult
                pkt2.res = (pkt.opa << 1) * pkt.opb;
              end
              default : pkt2.err = 1;
            endcase
          end
        endcase
      end
      else begin
        case(pkt.inp_valid)
          2'b00: pkt2.err = 1;
          2'b01:begin //only a valid
            case(pkt.cmd)
              4'b0110:begin //not_a
                pkt2.res = {1'b0, ~pkt.opa};
              end
              4'b1000:begin //shr1_a
                pkt2.res = {1'b0, pkt.opa >> 1};
              end
              4'b1001:begin //shl1_a
                pkt2.res = {1'b0, pkt.opa << 1};
              end
              default: pkt2.err = 1;
            endcase
           end
           2'b10:begin //only b valid
             case(pkt.cmd)
               4'b0111:begin
                 pkt2.res = {1'b0, ~pkt.opb};
               end
               4'b1010:begin
                 pkt2.res = {1'b0, pkt.opb >> 1};
               end
               4'b1011:begin
                 pkt2.res = {1'b0, pkt.opb << 1};
               end
               default: pkt2.err = 1;
             endcase
           end
           2'b11:begin
             case(pkt.cmd)
               4'b0000:begin
                 pkt2.res = pkt.opa & pkt.opb;
                 //$display("Enter inside add");
               end
               4'b0001:begin
                 pkt2.res = {1'b0, ~(pkt.opa & pkt.opb)};
                 $display("Enter inside nand");
               end
               4'b0010:begin
                 pkt2.res = pkt.opa | pkt.opb;
               end
               4'b0011:begin
                 pkt2.res = {1'b0, ~(pkt.opa | pkt.opb)};
               end
               4'b0100:begin
                 pkt2.res = pkt.opa ^ pkt.opb;
               end
               4'b0101:begin
                 pkt2.res = {1'b0, ~(pkt.opa ^ pkt.opb)};
               end
               4'b0110:begin //not_a
                 pkt2.res = {1'b0, ~pkt.opa};
               end
               4'b0111:begin
                 pkt2.res = {1'b0, ~pkt.opb};
               end
               4'b1000:begin //shr1_a
                 pkt2.res = {1'b0, pkt.opa >> 1};
               end
               4'b1001:begin //shl1_a
                 pkt2.res = {1'b0, pkt.opa << 1};
               end
               4'b1010:begin
                 pkt2.res = {1'b0, pkt.opb >> 1};
               end
               4'b1011:begin
                 pkt2.res = {1'b0, pkt.opb << 1};
               end
               4'b1100:begin
                 if( |(pkt.opb[W - 1 : SHIFT_WIDTH + 1]))begin
                   pkt2.err = 1;
                 end
                 else begin
                   pkt2.res = (pkt.opa << pkt.opb[SHIFT_WIDTH - 1 : 0]) | (pkt.opa >> (W - pkt.opb[SHIFT_WIDTH - 1 : 0]));
                   pkt.res[8] = 0;
                 end
               end
               4'b1101:begin
                 if(|pkt.opb[W-1: SHIFT_WIDTH + 1])begin
                   pkt2.err = 1;
                 end
                 else begin
                   pkt2.res = (pkt.opa >> pkt.opb[SHIFT_WIDTH - 1:0]) | (pkt.opa << (W - pkt.opb[SHIFT_WIDTH - 1: 0]));
                   pkt2.res[8] = 0;
                 end
               end
               default : pkt2.err = 1;
            endcase
          end
        endcase
      end
    end    
  endtask
  
  task run_phase(uvm_phase phase);
    int ERR;
    repeat(N*5)begin
      wait(q.size() > 0);
      $display("Arriving at scoreboard");
      scb_item = q.pop_front();
      ref_scb_item.copy(scb_item);
      calculate(scb_item, ref_scb_item);
      uvm_config_db#(int)::get(this, "", "ERR", ERR);
      if(ERR == 1)begin
        ref_scb_item.err = ERR;
      end
      //ref_scb_item.err = ERR;
      `uvm_info("MON OUTPUTS", $sformatf("res = %0d, err = %0d, cout = %0d, oflow = %0d, g = %0b, l = %0b, e = %0b", ref_scb_item.res, ref_scb_item.err, ref_scb_item.cout, ref_scb_item.oflow, ref_scb_item.g, ref_scb_item.l, ref_scb_item.e), UVM_LOW);  	
      if(scb_item.compare(ref_scb_item))begin
        `uvm_info("SCOREBOARD", "PASS", UVM_NONE)
        pass++;
      end
      else begin
        `uvm_info("SCOREBOARD", "FAIL", UVM_NONE)
        fail++;
      end
    end
    $display("Passes = %0d, Fails = %0d", pass, fail);
  endtask
endclass

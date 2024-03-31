// Description here
// ### Author : name (email)



module cdc_fifo_tb;

  `define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int ElemWidth = 4;
  localparam int FifoSize = 2;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generates static task start_clk_i with tHigh:3 tLow:7


  bit arst_ni = 1;
  `CREATE_CLK(elem_in_clk_i, 1000, 1000)
  bit [ElemWidth-1:0] elem_in_i;
  bit elem_in_valid_i = 0;
  bit elem_in_ready_o;
  `CREATE_CLK(elem_out_clk_i, 1001, 1001)
  bit [ElemWidth-1:0] elem_out_o;
  bit elem_out_valid_o;
  bit elem_out_ready_i = 0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INTERFACES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-CLASSES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  cdc_fifo #(
      .ELEM_WIDTH(ElemWidth),
      .FIFO_SIZE (FifoSize)
  ) cdc_pipeline_dut (
      .arst_ni(arst_ni),
      .elem_in_clk_i(elem_in_clk_i),
      .elem_in_i(elem_in_i),
      .elem_in_valid_i(elem_in_valid_i),
      .elem_in_ready_o(elem_in_ready_o),
      .elem_out_clk_i(elem_out_clk_i),
      .elem_out_o(elem_out_o),
      .elem_out_valid_o(elem_out_valid_o),
      .elem_out_ready_i(elem_out_ready_i)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  task static apply_reset();
    #100;
    arst_ni = 0;
    #100;
    arst_ni = 1;
    #100;
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial begin
    apply_reset();
    start_elem_in_clk_i();
    start_elem_out_clk_i();

    ////////////////////////////////////////////////////////////////////////////////////////////////
    fork
      forever begin
        @(posedge elem_in_clk_i);
        elem_in_i <= $urandom;
      end
    join_none

    fork
      begin
        @(posedge elem_in_clk_i);
        elem_in_valid_i <= '1;
      end
      begin
        @(posedge elem_out_clk_i);
        elem_out_ready_i <= '1;
      end
    join

    fork
      begin
        repeat (1500) @(posedge elem_in_clk_i);
      end
      begin
        repeat (1500) @(posedge elem_out_clk_i);
      end
    join
    ////////////////////////////////////////////////////////////////////////////////////////////////

    result_print(1, "This is a PASS");
    result_print(0, "And this is a FAIL");

    $finish;

  end

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////
//
// Author : Walid Akash (walidakash070@gmail.com)
// This file is part of squared-studio:common
// Copyright (c) 2025 squared-studio
// Licensed under the MIT License
// See LICENSE file in the project root for full license information
//
//////////////////////////////////////////////////////////////////////////////////////////////

module decoder_tb;

  ////////////////////////////////////////////////////////////////////////////////////////////
  //-INCLUDE
  ////////////////////////////////////////////////////////////////////////////////////////////

  `include "vip/tb_ess.sv"

  ///////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  ///////////////////////////////////////////////////////////////////////////////////////////

  localparam int NumWire = 5;

  //////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////

  `CREATE_CLK(clk_i, 2ns, 2ns)
  logic [$clog2(NumWire)-1:0] a_i = '0;
  logic                       a_valid_i = '0;
  logic [        NumWire-1:0] d_o;

  /////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  /////////////////////////////////////////////////////////////////////////////////////////

  logic [        NumWire-1:0] d_o_m;  // Output Port for Ref. Model
  int                         error = 0;  // Error Indicator

  ////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  ////////////////////////////////////////////////////////////////////////////////////////

  decoder #(
      .NUM_WIRE(NumWire)
  ) u_decoder (
      .a_i      (a_i),
      .a_valid_i(a_valid_i),
      .d_o      (d_o)
  );

  // Reference Model for Decoder
  always_comb begin : ref_decoder
    d_o_m = '0;
    d_o_m[a_i] = a_valid_i;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Driver for randomized stimuluses
  task static drive();
    fork
      forever
      @(posedge clk_i) begin
        a_i <= $urandom_range(0, $clog2(NumWire));
        a_valid_i <= $urandom_range(0, 1);
      end
    join_none
  endtask

  // Monitoring and Scoreboard
  task static monitor_scoreboard();
    fork
      forever
      @(posedge clk_i) begin
        for (int i = 0; i < NumWire; i++) begin
          if (d_o[i] !== d_o_m[i]) begin
            error++;
          end
        end
      end
    join_none
  endtask

  ///////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  ///////////////////////////////////////////////////////////////////////////////////////

  initial begin : decoder_test

    start_clk_i();
    drive();
    monitor_scoreboard();

    // Repeating the Test for N number of test cases - - - - > N = 32
    for (int k = 0; k <= 50; k++) begin
      @(posedge clk_i);

      // For Debugging purpose
`ifdef DEBUG
      $display("Test ------------------------------------- %d", k);
      $display("a_i = 0b%b", a_i);
      $display("a_valid_i = 0b%b", a_valid_i);
      $display("d_o = 0b%b", d_o);
      $display("d_o_m = 0b%b", d_o_m);
      $display("Error = %d", error);
`endif  // DEBUG
    end

    // Display Whether the Test passes or not
    result_print(error == 0, "decoder is passed");
    $finish;
  end

endmodule

/*
The `round_robin_arbiter` module is a round-robin arbiter with a configurable number of requests.
Author: Foez Ahmed (foez.official@gmail.com)
<br>This file is part of squared-studio:common
<br>Copyright (c) 2025 squared-studio
<br>Licensed under the MIT License
<br>See LICENSE file in the project root for full license information
*/

module round_robin_arbiter #(
    parameter int NUM_REQ = 4 // number of requests
) (
    input logic clk_i,   // Global clock
    input logic arst_ni, // Asynchronous reset

    input logic               allow_req_i,  // Allow requests
    input logic [NUM_REQ-1:0] req_i,        // Requests

    output logic [$clog2(NUM_REQ)-1:0] gnt_addr_o,       // Grant Address
    output logic                       gnt_addr_valid_o  // Grant Valid
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [$clog2(NUM_REQ)-1:0] last_gnt;  // last grant address

  logic [$clog2(NUM_REQ)-1:0] next_gnt;  // Next prioritized grant address

  logic [NUM_REQ-1:0] fpa_in;  // Fixed priority arbiter input

  logic [$clog2(NUM_REQ)-1:0] fpa_gnt_addr;  // Fixed priority arbiter address

  logic [NUM_REQ-1:0] fpa_gnt_addr_valid;  // Fixed priority arbiter address valid

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign gnt_addr_o = ((fpa_gnt_addr + next_gnt ) < NUM_REQ) ? (fpa_gnt_addr + next_gnt )
                      : ((fpa_gnt_addr + next_gnt) - NUM_REQ);

  assign next_gnt = ((last_gnt + 1) < NUM_REQ) ? (last_gnt + 1) : ((last_gnt + 1) - NUM_REQ);

  assign gnt_addr_valid_o = fpa_gnt_addr_valid & arst_ni;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  circular_xbar #(
      .ELEM_WIDTH(1),
      .NUM_ELEM  (NUM_REQ)
  ) circular_xbar_dut (
      .s_i(next_gnt),
      .i_i(req_i),
      .o_o(fpa_in)
  );

  fixed_priority_arbiter #(
      .NUM_REQ(NUM_REQ)
  ) fixed_priority_arbiter_dut (
      .allow_req_i(allow_req_i),
      .req_i(fpa_in),
      .gnt_addr_o(fpa_gnt_addr),
      .gnt_addr_valid_o(fpa_gnt_addr_valid)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      last_gnt <= NUM_REQ - 1;
    end else if (gnt_addr_valid_o) begin
      last_gnt <= gnt_addr_o;
    end
  end

endmodule

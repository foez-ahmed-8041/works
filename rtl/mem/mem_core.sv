////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    AUTHOR      : Foez Ahmed
//    EMAIL       : foez.official@gmail.com
//
//    MODULE      : mem_core
//    DESCRIPTION : basic building block for memory
//
////////////////////////////////////////////////////////////////////////////////////////////////////

/*
                           clk_i
                     --------↓---------
                    ¦                  ¦
 [AddrWidth] addr_i →                  ¦
[ElemWidth] wdata_i →     mem_core     → [CELL_WIDTG] rdata_o
               we_i →                  ¦
                    ¦                  ¦
                     ------------------
*/

module mem_core #(
    parameter int ElemWidth = 8,
    parameter int AddrWidth = 8
) (
    input  logic                 clk_i,
    input  logic                 we_i,
    input  logic [AddrWidth-1:0] addr_i,
    input  logic [ElemWidth-1:0] wdata_i,
    output logic [ElemWidth-1:0] rdata_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int Depth = (2 ** AddrWidth);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [Depth-1:0][ElemWidth-1:0] mem;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign rdata_o = mem[addr_i];

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENCIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_ff @(posedge clk_i) begin
    if (we_i) begin
      mem[addr_i] <= wdata_i;
    end
  end

endmodule

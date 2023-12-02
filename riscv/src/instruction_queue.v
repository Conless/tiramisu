module InstructionQueue #(
  // parameter 
) (
  // cpu status
  input wire clk,
  input wire rst,
  input wire rdy,

  // to instruction unit
  input wire inst_queue_entry_valid,
  input wire [ADDR_WIDTH+INST_WIDTH-1:0] inst_queue_entry,
  output wire inst_queue_ready,
)

endmodule
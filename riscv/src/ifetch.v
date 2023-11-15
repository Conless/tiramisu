module InstructionFetcher #(
    parameter INST_WIDTH  = 32,
    parameter ADDR_WIDTH  = 32,
    parameter CDB_WIDTH   = 32
  ) (
    // cpu status
    input wire clk,
    input wire rst,
    input wire rdy,

    // monitoring the common data bus
    input wire cdb_valid,
    input wire [CDB_WIDTH-1:0] cdb_data,

    // access to memory
    input wire rd_mem_done,
    input wire [INST_WIDTH-1:0] rd_mem_data,
    output wire [ADDR_WIDTH-1:0] rd_mem_valid,
    output wire [ADDR_WIDTH-1:0] rd_mem_addr
  );
  reg [ADDR_WIDTH-1:0] program_counter;

  always @(posedge clk) begin
    if (rst) begin
      // TODO(Conless): reset signal
    end
    else begin
      if (cdb_valid) begin
        // TODO(Conless): judge if there is predict result on common data bus
      end else begin
        // TODO(Conless): read data
      end
    end
  end

endmodule // InstructionFetcher

module InstructionCache #(
    parameter INST_WIDTH = 32,
    parameter ADDR_WIDTH = 17,
    parameter RAM_WIDTH = 32*4,
    parameter BLOCK_WIDTH = 2,
    parameter INDEX_WIDTH = 6,
    parameter TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH - BLOCK_WIDTH
  ) (
    input wire clk,
    input wire rst,
    input wire rdy,

    // to instruction fetcher
    input wire [ADDR_WIDTH-1:0] inst_cache_read_addr,
    output wire inst_cache_read_done,
    output wire [INST_WIDTH-1:0] inst_cache_read_data,

    // to ram
    input wire [RAM_WIDTH-1:0] dout_a,
    output reg [ADDR_WIDTH-1:0] addr_a
  );

  localparam IDLE = 0;
  localparam WAIT_MEM = 1;

  localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
  localparam BLOCK_INST_COUNT = 2 ** BLOCK_WIDTH;
  localparam BLOCK_SIZE = BLOCK_INST_COUNT * INST_WIDTH;

  reg status;

  reg cache_block_valid[BLOCK_COUNT-1:0];
  reg [TAG_WIDTH-1:0] cache_block_tag[BLOCK_COUNT-1:0];
  reg [BLOCK_SIZE-1:0] cache_block_data[BLOCK_COUNT-1:0];

  wire [INDEX_WIDTH-1:0] block_num;
  wire [BLOCK_SIZE-1:0] block_selected;
  wire [BLOCK_WIDTH-1:0] block_offset;
  wire [INST_WIDTH-1:0] block_insts[BLOCK_COUNT-1:0];

  wire hit;

  assign block_num = inst_cache_read_addr[BLOCK_WIDTH+INDEX_WIDTH-1:BLOCK_WIDTH];
  assign block_selected = cache_block_data[block_num];
  assign block_offset = inst_cache_read_addr[BLOCK_WIDTH-1:0];
  assign tag = inst_cache_read_addr[ADDR_WIDTH-1:ADDR_WIDTH-TAG_WIDTH];
  assign hit = cache_block_valid[block_num] && (cache_block_tag[block_num] == tag);

  // For debug use
  assign valid = cache_block_valid[block_num];

  genvar i;
  generate
    for (i = 0; i < BLOCK_COUNT; i = i + 1) begin
      assign block_insts[i] = block_selected[(i+1)*INST_WIDTH-1:i*INST_WIDTH];
    end
  endgenerate

  assign inst_cache_read_done = hit;
  assign inst_cache_read_data = block_insts[block_offset];

  integer j;

  always @(posedge clk) begin
    if (rst) begin
      status <= IDLE;
      status <= 0;
      for (j = 0; j < BLOCK_COUNT; j = j + 1) begin
        cache_block_valid[j] <= 0;
        cache_block_tag[j] <= 0;
        cache_block_data[j] <= 0;
      end
    end
    else if (rdy) begin
      case (status)
        IDLE: begin
          if (!hit) begin
            status <= WAIT_MEM;
            addr_a <= {tag, block_num, 2'b00};
          end
        end
        WAIT_MEM: begin
          cache_block_data[block_num] <= dout_a;
          cache_block_valid[block_num] <= 1;
          status <= IDLE;
        end
      endcase
    end
  end
endmodule

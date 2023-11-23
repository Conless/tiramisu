module ram #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8,
    parameter RAM_WIDTH = 32
  )
  (
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire [ADDR_WIDTH-1:0] addr_a,
    output reg [RAM_WIDTH-1:0] dout_a,

    input wire [ADDR_WIDTH-1:0] addr_b,
    input wire [RAM_WIDTH-1:0] din_b,
    input wire we_b,
    output reg [RAM_WIDTH-1:0] dout_b
  );

  reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
  reg [ADDR_WIDTH-1:0] q_addr_a;
  reg [ADDR_WIDTH-1:0] q_addr_b;

  always @(posedge clk) begin
    if (we)
      ram[addr_a] <= din_a;
    dout_a <= ram[q_addr_a];
    dout_b <= ram[q_addr_b];
  end

endmodule

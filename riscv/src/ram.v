module RandomAccessMemory #(
    parameter ADDR_WIDTH = 17,
    parameter DATA_WIDTH = 8,
    parameter RAM_WIDTH = 32*4
  )
  (
    input wire clk,

    input wire [ADDR_WIDTH-1:0] addr_a,
    output wire [RAM_WIDTH-1:0] dout_a,

    input wire [ADDR_WIDTH-1:0] addr_b,
    input wire [RAM_WIDTH-1:0] din_b,
    input wire we_b,
    output wire [RAM_WIDTH-1:0] dout_b
  );

  integer i;
  initial begin
    for (i = 0; i < 2 ** ADDR_WIDTH; i = i + 1) begin
      ram[i] = 0;
    end
    $readmemh("test.data", ram);
  end

  reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];

  assign dout_a = {ram[addr_a], ram[addr_a + 1], ram[addr_a + 2], ram[addr_a + 3], ram[addr_a + 4], ram[addr_a + 5], ram[addr_a + 6], ram[addr_a + 7], ram[addr_a + 8], ram[addr_a + 9], ram[addr_a + 10], ram[addr_a + 11], ram[addr_a + 12], ram[addr_a + 13], ram[addr_a + 14], ram[addr_a + 15]};
  assign dout_b = {ram[addr_b], ram[addr_b + 1], ram[addr_b + 2], ram[addr_b + 3], ram[addr_b + 4], ram[addr_b + 5], ram[addr_b + 6], ram[addr_b + 7], ram[addr_b + 8], ram[addr_b + 9], ram[addr_b + 10], ram[addr_b + 11], ram[addr_b + 12], ram[addr_b + 13], ram[addr_b + 14], ram[addr_b + 15]};

  always @(posedge clk) begin
    if (we_b) begin
      ram[addr_b] <= din_b;
    end
  end

endmodule

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

  genvar j;
  generate
    for (j = 0; j < RAM_WIDTH / DATA_WIDTH; j = j + 1) begin
      assign dout_a[j*DATA_WIDTH+DATA_WIDTH-1:j*DATA_WIDTH] = ram[addr_a+j];
      assign dout_b[j*DATA_WIDTH+DATA_WIDTH-1:j*DATA_WIDTH] = ram[addr_b+j];
    end
  endgenerate

  always @(posedge clk) begin
    if (we_b) begin
      ram[addr_b] <= din_b;
    end
  end

endmodule

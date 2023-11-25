// riscv top module file
// modification allowed for debugging purposes

module riscv_top #(
    parameter ADDR_WIDTH = 17,
    parameter RAM_WIDTH = 32*4
  )(
    input wire extern_clk,
    input wire extern_rst
  );

  wire clk;
  assign clk = extern_clk;

  reg rst;
  reg rst_delay;

  always @(posedge clk or posedge rst) begin
    if (extern_rst) begin
      rst <= 1;
      rst_delay <= 1;
    end
    else begin
      rst_delay <= 0;
      rst <= rst_delay;
    end
  end

  // outports wire
  wire [ADDR_WIDTH-1:0] 	addr_a;
  wire [RAM_WIDTH-1:0]  	dout_a;
  wire [ADDR_WIDTH-1:0] 	addr_b;
  wire [RAM_WIDTH-1:0]   	din_b;
  wire                   	we_b;
  wire [RAM_WIDTH-1:0]  	dout_b;

  RandomAccessMemory #(
                       .ADDR_WIDTH(ADDR_WIDTH),
                       .RAM_WIDTH(RAM_WIDTH)
                     ) ram
                     (
                       .clk    	( clk     ),
                       .addr_a 	( addr_a  ),
                       .dout_a 	( dout_a  ),
                       .addr_b 	( addr_b  ),
                       .din_b  	( din_b   ),
                       .we_b   	( we_b    ),
                       .dout_b 	( dout_b  )
                     );


  //
  // CPU: CPU that implements RISC-V 32b integer base user-level real-mode ISA
  //

  CentralProcessingUnit #(
                          .ADDR_WIDTH(ADDR_WIDTH),
                          .RAM_WIDTH(RAM_WIDTH)
                        ) cpu(
                          .clk            	( clk             ),
                          .rst            	( rst             ),
                          .rdy            	( 1'b1            ),
                          .dout_a         	( dout_a          ),
                          .addr_a         	( addr_a          ),
                          .dout_b         	( dout_b          ),
                          .addr_b         	( addr_b          ),
                          .din_b          	( din_b           ),
                          .we_b           	( we_b            )
                        );

endmodule

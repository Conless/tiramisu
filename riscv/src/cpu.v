// RISCV32I CPU top module
// port modification allowed for debugging purposes

module CentralProcessingUnit #(
    parameter ADDR_WIDTH = 17,
    parameter INST_WIDTH = 32,
    parameter RAM_WIDTH = 32 * 4
  ) (
    input wire         clk,
    input wire         rst,
    input wire         rdy,

    input wire [RAM_WIDTH-1:0] dout_a,
    output wire [ADDR_WIDTH-1:0] addr_a,

    input wire [RAM_WIDTH-1:0] dout_b,
    output wire [ADDR_WIDTH-1:0] addr_b,
    output wire [RAM_WIDTH-1:0] din_b,
    output wire we_b
  );

  // implementation goes here

  // Specifications:
  // - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
  // - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
  // - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
  // - I/O port is mapped to address higher than 0x30000 (mem_a[17:16] == 2'b11)
  // - 0x30000 read: read a byte from input
  // - 0x30000 write: write a byte to output (write 0x00 is ignored)
  // - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
  // - 0x30004 write: indicates program stop (will output '\0' through uart tx)

  // Instruction Unit <--> Instruction Cache
  wire [ADDR_WIDTH-1:0] 	inst_cache_read_addr;
  wire                  	inst_cache_read_done;
  wire [INST_WIDTH-1:0] 	inst_cache_read_data;

  // Instruction Unit <--> Instruction Queue
  wire                  	          inst_queue_entry_valid;
  wire [ADDR_WIDTH+INST_WIDTH-1:0] 	inst_queue_entry;
  wire                 	            inst_queue_ready;
  
  InstructionUnit ins_unit(
    .clk                  	( clk                    ),
    .rst                  	( rst                    ),
    .rdy                  	( rdy                    ),
    .cdb_valid            	(                        ),
    .cdb_data             	(                        ),
    .inst_cache_read_done 	( inst_cache_read_done   ),
    .inst_cache_read_data 	( inst_cache_read_data   ),
    .inst_cache_read_addr 	( inst_cache_read_addr   ),
    .inst_queue_ready    	  ( inst_queue_ready       ),
    .inst_queue_entry_valid ( inst_queue_entry_valid ),
    .inst_queue_entry     	( inst_queue_entry       )
  );

  
  InstructionCache ins_cache(
    .clk                  	( clk                   ),
    .rst                  	( rst                   ),
    .rdy                  	( rdy                   ),
    .inst_cache_read_addr 	( inst_cache_read_addr  ),
    .inst_cache_read_done 	( inst_cache_read_done  ),
    .inst_cache_read_data 	( inst_cache_read_data  ),
    .dout_a               	( dout_a                ),
    .addr_a               	( addr_a                )
  );

  InstructionQueue ins_queue(
    .clk                  	( clk                    ),
    .rst                  	( rst                    ),
    .rdy                  	( rdy                    ),
    .inst_queue_entry_valid ( inst_queue_entry_valid ),
    .inst_queue_entry     	( inst_queue_entry       ),
    .inst_queue_ready     	( inst_queue_ready       )
  );
  
  

  always @(posedge clk) begin
    if (rst) begin

    end
    else if (!rdy) begin

    end
    else begin

    end
  end

endmodule

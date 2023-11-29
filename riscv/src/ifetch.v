module InstructionFetcher #(
    parameter INST_WIDTH  = 32,
    parameter ADDR_WIDTH  = 17,
    parameter CDB_WIDTH   = 32
  ) (
    // cpu status
    input wire clk,
    input wire rst,
    input wire rdy,

    // monitoring the common data bus
    input wire cdb_valid,
    input wire [CDB_WIDTH-1:0] cdb_data,

    // to instrcution cache
    input wire inst_cache_read_done,
    input wire [INST_WIDTH-1:0] inst_cache_read_data,
    output wire [ADDR_WIDTH-1:0] inst_cache_read_addr,

    // to instruction decode
    input wire inst_decode_ready,
    output reg inst_decode_valid,
    output wire [INST_WIDTH-1:0] inst_decode_data
  );

  localparam IDLE = 2'b00;
  localparam WAIT_MEM = 2'b01;
  localparam WAIT_DECODE = 2'b10;
  localparam STALL = 2'b11;

  reg [1:0] status; // default value is 2'b00, i.e. idle
  reg [ADDR_WIDTH-1:0] program_counter; // default value is 0, i.e. program start from 0x0

  assign inst_cache_read_addr = program_counter;
  assign inst_decode_data = inst_cache_read_data;

  always @(posedge clk) begin
    if (rst) begin
      status <= 0;
      program_counter <= 0;
    end
    else if (rdy) begin
      if (inst_decode_ready) begin // It means instruction decoder will accept that instruction in current cycle, so we can set valid signal to 0
        inst_decode_valid <= 0;
      end

      case (status) // Finite state machine
        IDLE: begin // Ready to fetch next instruction
          status <= WAIT_MEM;
        end
        WAIT_MEM: begin
          if (inst_cache_read_done) begin // Instruction cache has read the instruction
            if (inst_decode_ready) begin // Instruction decoder is ready to accept the instruction
              status <= IDLE;
            end else begin // Instruction decoder is not ready to accept the instruction
              status <= WAIT_DECODE;
            end
            inst_decode_valid <= 1;
          end
        end
        WAIT_DECODE: begin
          if (inst_decode_ready) begin // Instruction decoder is ready to accept the instruction
            if (0) begin
              // TODO(Conless): branch instruction
            end else begin
              status <= IDLE;
              program_counter <= program_counter + 4; // Next instruction
            end
          end
        end
        STALL: begin // Wait for branch target
          if (cdb_valid) begin
            // TODO(Conless): monitor data on common data bus
            status <= IDLE;
          end
        end
      endcase
    end
  end

endmodule // InstructionFetcher

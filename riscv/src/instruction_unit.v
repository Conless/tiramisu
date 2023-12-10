module InstructionUnit #(
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

    // to instruction queue
    input wire inst_queue_ready,
    output reg inst_queue_entry_valid,
    output wire [ADDR_WIDTH+INST_WIDTH-1:0] inst_queue_entry // low bits store instruction, high bits store program counter
  );

  localparam IDLE = 2'b00;
  localparam WAIT_MEM = 2'b01;
  localparam WAIT_QUEUE = 2'b10;
  localparam STALL = 2'b11;

  reg [1:0] status; // default value is 2'b00, i.e. idle
  reg [ADDR_WIDTH-1:0] program_counter; // default value is 0, i.e. program start from 0x0

  assign inst_cache_read_addr = program_counter;
  assign inst_queue_entry = {program_counter, inst_cache_read_data};

  always @(posedge clk) begin
    if (rst) begin
      status <= 0;
      program_counter <= 0;
    end
    else if (rdy) begin
      if (inst_queue_ready && inst_queue_entry_valid) begin // It means instruction queue will accept that instruction in current cycle, so we can set valid signal to 0
        inst_queue_entry_valid <= 0;
      end

      case (status) // Finite state machine
        IDLE: begin // Ready to fetch next instruction
          status <= WAIT_MEM;
        end
        WAIT_MEM: begin
          if (inst_cache_read_done) begin // Instruction cache has read the instruction
            if (inst_queue_ready) begin // Instruction queue is ready to accept the instruction
              status <= IDLE;
              program_counter <= program_counter + 4; // Next instruction
            end else begin // Instruction queue is not ready to accept the instruction
              status <= WAIT_QUEUE;
            end
            inst_queue_entry_valid <= 1;
          end
        end
        WAIT_QUEUE: begin
          if (inst_queue_ready) begin // Instruction queue is ready to accept the instruction
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

module InstructionQueue #(
    parameter INST_WIDTH = 32,
    parameter ADDR_WIDTH = 17,
    parameter OPCODE_WIDTH = 7,
    parameter REG_NUM_WIDTH = 5,
    parameter IMM_WIDTH = 32,
    parameter QUEUE_ADDR_WIDTH = 4
  )(
    // cpu status
    input wire clk,
    input wire rst,
    input wire rdy,

    // to instruction unit
    input wire inst_queue_entry_valid,
    input wire [ADDR_WIDTH+INST_WIDTH-1:0] inst_queue_entry,
    output wire inst_queue_ready

    // to scoreboard
  );

  localparam QUEUE_SIZE = 2**QUEUE_ADDR_WIDTH;

  localparam OPCODE_LUI   = 7'b0110111;
  localparam OPCODE_AUIPC = 7'b0010111;
  localparam OPCODE_JAL   = 7'b1101111;
  localparam OPCODE_JALR  = 7'b1100111;
  localparam OPCODE_BRANCH     = 7'b1100011;
  localparam OPCODE_LOAD = 7'b0000011;
  localparam OPCODE_STORE = 7'b0100011;
  localparam OPCODE_ARITHI = 7'b0010011;
  localparam OPCODE_ARITH = 7'b0110011;

  reg [ADDR_WIDTH-1:0] addr[QUEUE_SIZE-1:0]; // program counter
  reg [OPCODE_WIDTH-1:0] opcode[QUEUE_SIZE-1:0]; // opcode
  reg [REG_NUM_WIDTH-1:0] rs1[QUEUE_SIZE-1:0]; // rs1 number
  reg [REG_NUM_WIDTH-1:0] rs2[QUEUE_SIZE-1:0]; // rs2 number
  reg [REG_NUM_WIDTH-1:0] rd[QUEUE_SIZE-1:0]; // rd number
  reg [IMM_WIDTH-1:0] imm[QUEUE_SIZE-1:0]; // immediate value

  reg valid[QUEUE_SIZE-1:0]; // whether the entry is valid
  reg [QUEUE_ADDR_WIDTH-1:0] head;
  reg [QUEUE_ADDR_WIDTH-1:0] tail;

  integer i;

  wire [OPCODE_WIDTH-1:0] inst_queue_entry_opcode;
  wire [2:0] inst_queue_entry_tag;
  wire inst_queue_entry_imm_high;

  assign inst_queue_ready = (head != tail) || !valid[head];
  assign inst_queue_entry_opcode = inst_queue_entry[OPCODE_WIDTH-1:0];
  assign inst_queue_entry_rs1 = inst_queue_entry[19:5];
  assign inst_queue_entry_rs2 = inst_queue_entry[24:20];
  assign inst_queue_entry_rd = inst_queue_entry[11:7];
  assign inst_queue_entry_tag = inst_queue_entry[OPCODE_WIDTH+REG_NUM_WIDTH+2:OPCODE_WIDTH+REG_NUM_WIDTH];
  assign inst_queue_entry_imm_high = inst_queue_entry[OPCODE_WIDT-1];

  always @(posedge clk) begin
    if (rst) begin
      head <= 0;
      tail <= 0;
      for (i = 0; i < QUEUE_SIZE; i = i + 1) begin
        addr[i] <= 0;
        opcode[i] <= 0;
        rs1[i] <= 0;
        rs2[i] <= 0;
        rd[i] <= 0;
        imm[i] <= 0;
        valid[i] <= 0;
      end
    end
    else if (rdy) begin
      if (inst_queue_ready && inst_queue_entry_valid) begin
        tail <= tail + 1'b1;
        addr[tail] <= inst_queue_entry[ADDR_WIDTH+INST_WIDTH-1:INST_WIDTH];
        opcode[tail] <= inst_queue_entry_opcode;
        rs1[tail] <= inst_queue_entry_rs1;
        rs2[tail] <= inst_queue_entry_rs2;
        rd[tail] <= inst_queue_entry_rd;
        case (inst_queue_entry_opcode)
          OPCODE_LUI, OPCODE_AUIPC: begin
            imm[tail] <= {inst_queue_entry[31:12], 12'b0};
          end
          OPCODE_JAL: begin
            imm[tail] <= {{11{inst_queue_entry_imm_high}}, inst_queue_entry[31], inst_queue_entry[19:12], inst_queue_entry[20], inst_queue_entry[30:21], 1'b0};
          end
          OPCODE_JALR: begin
            imm[tail] <= {{20{inst_queue_entry_imm_high}}, inst_queue_entry[31:20]};
          end
          OPCODE_BRANCH: begin
            imm[tail] <= {{19{inst_queue_entry_imm_high}}, inst_queue_entry[31], inst_queue_entry[7], inst_queue_entry[30:25], inst_queue_entry[11:8], 1'b0};
          end
          OPCODE_LOAD: begin
            imm[tail] <= {{20{inst_queue_entry_imm_high}}, inst_queue_entry[31:20]};
          end
          OPCODE_STORE: begin
            imm[tail] <= {{20{inst_queue_entry_imm_high}}, inst_queue_entry[31:25], inst_queue_entry[11:7]};
          end
          OPCODE_ARITHI: begin
            imm[tail] <= {{20{inst_queue_entry_imm_high}}, inst_queue_entry[31:20]};
          end
          OPCODE_ARITH: begin
            imm[tail] <= 0;
          end
        endcase
      end
    end
  end


endmodule

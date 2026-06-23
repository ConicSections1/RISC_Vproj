module control_unit (
    input  logic [31:0] instr,
    output logic        reg_write,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic [1:0]  result_src,
    output logic        branch,
    output logic        jump,
    output logic        jump_reg,
    output logic [1:0]  alu_op,
    output logic [2:0]  imm_sel
);
    localparam logic [6:0] OPCODE_LOAD     = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE    = 7'b0100011;
    localparam logic [6:0] OPCODE_OP_IMM   = 7'b0010011;
    localparam logic [6:0] OPCODE_OP       = 7'b0110011;
    localparam logic [6:0] OPCODE_LUI      = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC    = 7'b0010111;
    localparam logic [6:0] OPCODE_BRANCH   = 7'b1100011;
    localparam logic [6:0] OPCODE_JAL      = 7'b1101111;
    localparam logic [6:0] OPCODE_JALR     = 7'b1100111;

    localparam logic [2:0] IMM_I = 3'b000;
    localparam logic [2:0] IMM_S = 3'b001;
    localparam logic [2:0] IMM_B = 3'b010;
    localparam logic [2:0] IMM_U = 3'b011;
    localparam logic [2:0] IMM_J = 3'b100;

    localparam logic [1:0] RESULT_ALU = 2'b00;
    localparam logic [1:0] RESULT_MEM = 2'b01;
    localparam logic [1:0] RESULT_PC4 = 2'b10;
    localparam logic [1:0] RESULT_IMM = 2'b11;

    localparam logic [1:0] ALU_OP_LOAD_STORE_IMM = 2'b00;
    localparam logic [1:0] ALU_OP_BRANCH         = 2'b01;
    localparam logic [1:0] ALU_OP_R_TYPE         = 2'b10;
    localparam logic [1:0] ALU_OP_I_TYPE         = 2'b11;

    logic [6:0] opcode;

    assign opcode = instr[6:0];

    always_comb begin
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read  = 1'b0;
        alu_src   = 1'b0;
        result_src = RESULT_ALU;
        branch    = 1'b0;
        jump      = 1'b0;
        jump_reg  = 1'b0;
        alu_op    = ALU_OP_LOAD_STORE_IMM;
        imm_sel   = IMM_I;

        case (opcode)
            OPCODE_OP: begin
                reg_write = 1'b1;
                alu_op    = ALU_OP_R_TYPE;
                imm_sel   = IMM_I;
            end
            OPCODE_OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_I_TYPE;
                imm_sel   = IMM_I;
            end
            OPCODE_LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_src   = 1'b1;
                result_src = RESULT_MEM;
                alu_op    = ALU_OP_LOAD_STORE_IMM;
                imm_sel   = IMM_I;
            end
            OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_LOAD_STORE_IMM;
                imm_sel   = IMM_S;
            end
            OPCODE_BRANCH: begin
                branch    = 1'b1;
                alu_op    = ALU_OP_BRANCH;
                imm_sel   = IMM_B;
            end
            OPCODE_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                result_src = RESULT_IMM;
                imm_sel   = IMM_U;
            end
            OPCODE_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                result_src = RESULT_ALU;
                alu_op    = ALU_OP_LOAD_STORE_IMM;
                imm_sel   = IMM_U;
            end
            OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                result_src = RESULT_PC4;
                imm_sel   = IMM_J;
            end
            OPCODE_JALR: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                jump      = 1'b1;
                jump_reg  = 1'b1;
                result_src = RESULT_PC4;
                alu_op    = ALU_OP_LOAD_STORE_IMM;
                imm_sel   = IMM_I;
            end
            default: begin
                reg_write = 1'b0;
            end
        endcase
    end
endmodule

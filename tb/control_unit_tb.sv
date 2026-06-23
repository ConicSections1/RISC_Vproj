module control_unit_tb;
    logic [31:0] instr;
    logic        reg_write;
    logic        mem_write;
    logic        mem_read;
    logic        alu_src;
    logic [1:0]  result_src;
    logic        branch;
    logic        jump;
    logic        jump_reg;
    logic [1:0]  alu_op;
    logic [2:0]  imm_sel;

    localparam logic [6:0] OPCODE_LOAD     = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE    = 7'b0100011;
    localparam logic [6:0] OPCODE_OP_IMM   = 7'b0010011;
    localparam logic [6:0] OPCODE_OP       = 7'b0110011;
    localparam logic [6:0] OPCODE_LUI      = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC    = 7'b0010111;
    localparam logic [6:0] OPCODE_BRANCH   = 7'b1100011;
    localparam logic [6:0] OPCODE_JAL      = 7'b1101111;
    localparam logic [6:0] OPCODE_JALR     = 7'b1100111;
    localparam logic [6:0] OPCODE_ILLEGAL  = 7'b0001011;

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

    control_unit dut (
        .instr(instr),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .result_src(result_src),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .alu_op(alu_op),
        .imm_sel(imm_sel)
    );

    function automatic logic [31:0] encode_r(
        input logic [6:0] funct7,
        input logic [4:0] rs2,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [4:0] rd,
        input logic [6:0] opcode
    );
        encode_r = {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_i(
        input logic signed [11:0] imm12,
        input logic [4:0] rd,
        input logic [2:0] funct3,
        input logic [4:0] rs1,
        input logic [6:0] opcode
    );
        encode_i = {imm12[11:0], rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_s(
        input logic signed [11:0] imm12,
        input logic [4:0] rs2,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [6:0] opcode
    );
        encode_s = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], opcode};
    endfunction

    function automatic logic [31:0] encode_b(
        input logic signed [12:0] imm13,
        input logic [4:0] rs2,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [6:0] opcode
    );
        encode_b = {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], opcode};
    endfunction

    function automatic logic [31:0] encode_u(
        input logic [19:0] imm20,
        input logic [4:0] rd,
        input logic [6:0] opcode
    );
        encode_u = {imm20, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_j(
        input logic signed [20:0] imm21,
        input logic [4:0] rd,
        input logic [6:0] opcode
    );
        encode_j = {imm21[20], imm21[10:1], imm21[11], imm21[19:12], rd, opcode};
    endfunction

    task automatic check_controls(
        input logic        expected_reg_write,
        input logic        expected_mem_write,
        input logic        expected_mem_read,
        input logic        expected_alu_src,
        input logic [1:0]  expected_result_src,
        input logic        expected_branch,
        input logic        expected_jump,
        input logic        expected_jump_reg,
        input logic [1:0]  expected_alu_op,
        input logic [2:0]  expected_imm_sel,
        input string       test_name
    );
        begin
            #1;
            if (reg_write !== expected_reg_write ||
                mem_write !== expected_mem_write ||
                mem_read !== expected_mem_read ||
                alu_src !== expected_alu_src ||
                result_src !== expected_result_src ||
                branch !== expected_branch ||
                jump !== expected_jump ||
                jump_reg !== expected_jump_reg ||
                alu_op !== expected_alu_op ||
                imm_sel !== expected_imm_sel) begin
                $display("FAIL: %s", test_name);
                $display("  got      rw=%0b mw=%0b mr=%0b as=%0b rs=%0b br=%0b j=%0b jr=%0b ao=%b is=%b",
                         reg_write, mem_write, mem_read, alu_src, result_src, branch, jump, jump_reg, alu_op, imm_sel);
                $display("  expected rw=%0b mw=%0b mr=%0b as=%0b rs=%0b br=%0b j=%0b jr=%0b ao=%b is=%b",
                         expected_reg_write, expected_mem_write, expected_mem_read, expected_alu_src, expected_result_src,
                         expected_branch, expected_jump, expected_jump_reg, expected_alu_op, expected_imm_sel);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, control_unit_tb);

        instr = encode_r(7'b0000000, 5'd3, 5'd2, 3'b000, 5'd1, OPCODE_OP);
        check_controls(1'b1, 1'b0, 1'b0, 1'b0, RESULT_ALU, 1'b0, 1'b0, 1'b0, ALU_OP_R_TYPE, IMM_I, "R-type control");

        instr = encode_i(12'sd12, 5'd1, 3'b000, 5'd2, OPCODE_OP_IMM);
        check_controls(1'b1, 1'b0, 1'b0, 1'b1, RESULT_ALU, 1'b0, 1'b0, 1'b0, ALU_OP_I_TYPE, IMM_I, "I-type ALU control");

        instr = encode_i(12'sd8, 5'd1, 3'b010, 5'd2, OPCODE_LOAD);
        check_controls(1'b1, 1'b0, 1'b1, 1'b1, RESULT_MEM, 1'b0, 1'b0, 1'b0, ALU_OP_LOAD_STORE_IMM, IMM_I, "Load control");

        instr = encode_s(12'sd16, 5'd3, 5'd2, 3'b010, OPCODE_STORE);
        check_controls(1'b0, 1'b1, 1'b0, 1'b1, RESULT_ALU, 1'b0, 1'b0, 1'b0, ALU_OP_LOAD_STORE_IMM, IMM_S, "Store control");

        instr = encode_b(13'sd20, 5'd3, 5'd2, 3'b000, OPCODE_BRANCH);
        check_controls(1'b0, 1'b0, 1'b0, 1'b0, RESULT_ALU, 1'b1, 1'b0, 1'b0, ALU_OP_BRANCH, IMM_B, "Branch control");

        instr = encode_u(20'hABCDE, 5'd4, OPCODE_LUI);
        check_controls(1'b1, 1'b0, 1'b0, 1'b1, RESULT_IMM, 1'b0, 1'b0, 1'b0, ALU_OP_LOAD_STORE_IMM, IMM_U, "LUI control");

        instr = encode_u(20'h12345, 5'd4, OPCODE_AUIPC);
        check_controls(1'b1, 1'b0, 1'b0, 1'b1, RESULT_ALU, 1'b0, 1'b0, 1'b0, ALU_OP_LOAD_STORE_IMM, IMM_U, "AUIPC control");

        instr = encode_j(21'sd2048, 5'd1, OPCODE_JAL);
        check_controls(1'b1, 1'b0, 1'b0, 1'b0, RESULT_PC4, 1'b0, 1'b1, 1'b0, ALU_OP_LOAD_STORE_IMM, IMM_J, "JAL control");

        instr = encode_i(12'sd4, 5'd1, 3'b000, 5'd2, OPCODE_JALR);
        check_controls(1'b1, 1'b0, 1'b0, 1'b1, RESULT_PC4, 1'b0, 1'b1, 1'b1, ALU_OP_LOAD_STORE_IMM, IMM_I, "JALR control");

        instr = {25'h0, OPCODE_ILLEGAL};
        check_controls(1'b0, 1'b0, 1'b0, 1'b0, RESULT_ALU, 1'b0, 1'b0, 1'b0, ALU_OP_LOAD_STORE_IMM, IMM_I, "Illegal opcode defaults");

        $display("All control unit tests passed.");
        $finish;
    end
endmodule

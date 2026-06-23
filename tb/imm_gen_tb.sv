module imm_gen_tb;
    logic [31:0] instr;
    logic [2:0]  imm_sel;
    logic [31:0] imm;

    localparam logic [2:0] IMM_I = 3'b000;
    localparam logic [2:0] IMM_S = 3'b001;
    localparam logic [2:0] IMM_B = 3'b010;
    localparam logic [2:0] IMM_U = 3'b011;
    localparam logic [2:0] IMM_J = 3'b100;

    imm_gen dut (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

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

    task automatic check_imm(
        input logic [31:0] expected_imm,
        input string       test_name
    );
        begin
            #1;
            if (imm !== expected_imm) begin
                $display("FAIL: %s | expected imm=%h, got imm=%h", test_name, expected_imm, imm);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, imm_gen_tb);

        imm_sel = IMM_I;
        instr = encode_i(12'sd203, 5'd1, 3'b000, 5'd2, 7'b0010011);
        check_imm(32'h0000_00CB, "I-type positive immediate");

        instr = encode_i(-12'sd16, 5'd1, 3'b000, 5'd2, 7'b0010011);
        check_imm(32'hFFFF_FFF0, "I-type negative immediate");

        imm_sel = IMM_S;
        instr = encode_s(12'sd60, 5'd3, 5'd4, 3'b010, 7'b0100011);
        check_imm(32'h0000_003C, "S-type positive immediate");

        instr = encode_s(-12'sd32, 5'd3, 5'd4, 3'b010, 7'b0100011);
        check_imm(32'hFFFF_FFE0, "S-type negative immediate");

        imm_sel = IMM_B;
        instr = encode_b(13'sd182, 5'd5, 5'd6, 3'b001, 7'b1100011);
        check_imm(32'h0000_00B6, "B-type positive immediate");

        instr = encode_b(-13'sd20, 5'd5, 5'd6, 3'b001, 7'b1100011);
        check_imm(32'hFFFF_FFEC, "B-type negative immediate");

        imm_sel = IMM_U;
        instr = encode_u(20'hABCDE, 5'd7, 7'b0110111);
        check_imm(32'hABCDE000, "U-type immediate");

        imm_sel = IMM_J;
        instr = encode_j(21'sd74564, 5'd8, 7'b1101111);
        check_imm(32'h0001_2344, "J-type positive immediate");

        instr = encode_j(-21'sd2048, 5'd8, 7'b1101111);
        check_imm(32'hFFFF_F800, "J-type negative immediate");

        $display("All immediate generator tests passed.");
        $finish;
    end
endmodule

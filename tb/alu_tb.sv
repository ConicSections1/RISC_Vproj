module alu_tb;
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [3:0]  alu_ctrl;
    logic [31:0] result;
    logic        zero;

    localparam logic [3:0] ALU_CTRL_ADD  = 4'b0000;
    localparam logic [3:0] ALU_CTRL_SUB  = 4'b0001;
    localparam logic [3:0] ALU_CTRL_AND  = 4'b0010;
    localparam logic [3:0] ALU_CTRL_OR   = 4'b0011;
    localparam logic [3:0] ALU_CTRL_XOR  = 4'b0100;
    localparam logic [3:0] ALU_CTRL_SLT  = 4'b0101;
    localparam logic [3:0] ALU_CTRL_SLTU = 4'b0110;
    localparam logic [3:0] ALU_CTRL_SLL  = 4'b0111;
    localparam logic [3:0] ALU_CTRL_SRL  = 4'b1000;
    localparam logic [3:0] ALU_CTRL_SRA  = 4'b1001;
    localparam logic [3:0] ALU_CTRL_PASS = 4'b1010;

    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    task automatic check_result(
        input logic [31:0] expected_result,
        input logic        expected_zero,
        input string       test_name
    );
        begin
            #1;
            if (result !== expected_result || zero !== expected_zero) begin
                $display("FAIL: %s | expected result=%h zero=%0b, got result=%h zero=%0b", test_name, expected_result, expected_zero, result, zero);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);

        operand_a = 32'd10;
        operand_b = 32'd5;

        alu_ctrl = ALU_CTRL_ADD;
        check_result(32'd15, 1'b0, "ADD");

        alu_ctrl = ALU_CTRL_SUB;
        check_result(32'd5, 1'b0, "SUB");

        alu_ctrl = ALU_CTRL_AND;
        check_result(32'd0, 1'b1, "AND");

        alu_ctrl = ALU_CTRL_OR;
        check_result(32'd15, 1'b0, "OR");

        alu_ctrl = ALU_CTRL_XOR;
        check_result(32'd15, 1'b0, "XOR");

        operand_a = 32'hFFFF_FFFC;
        operand_b = 32'd1;
        alu_ctrl = ALU_CTRL_SLT;
        check_result(32'd1, 1'b0, "SLT signed");

        operand_a = 32'hFFFF_FFFC;
        operand_b = 32'd1;
        alu_ctrl = ALU_CTRL_SLTU;
        check_result(32'd0, 1'b1, "SLTU unsigned");

        operand_a = 32'h0000_0001;
        operand_b = 32'd3;
        alu_ctrl = ALU_CTRL_SLL;
        check_result(32'd8, 1'b0, "SLL");

        operand_a = 32'h0000_0008;
        operand_b = 32'd3;
        alu_ctrl = ALU_CTRL_SRL;
        check_result(32'd1, 1'b0, "SRL");

        operand_a = 32'h8000_0000;
        operand_b = 32'd3;
        alu_ctrl = ALU_CTRL_SRA;
        check_result(32'hF000_0000, 1'b0, "SRA");

        operand_b = 32'h1234_5678;
        alu_ctrl = ALU_CTRL_PASS;
        check_result(32'h1234_5678, 1'b0, "PASS");

        $display("All ALU tests passed.");
        $finish;
    end
endmodule

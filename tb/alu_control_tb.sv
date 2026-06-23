module alu_control_tb;
    logic [1:0] alu_op;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [3:0] alu_ctrl;

    localparam logic [1:0] ALU_OP_LOAD_STORE_IMM = 2'b00;
    localparam logic [1:0] ALU_OP_BRANCH         = 2'b01;
    localparam logic [1:0] ALU_OP_R_TYPE         = 2'b10;
    localparam logic [1:0] ALU_OP_I_TYPE         = 2'b11;

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

    alu_control dut (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl)
    );

    task automatic check_ctrl(
        input logic [3:0] expected_ctrl,
        input string      test_name
    );
        begin
            #1;
            if (alu_ctrl !== expected_ctrl) begin
                $display("FAIL: %s | expected ctrl=%b, got ctrl=%b", test_name, expected_ctrl, alu_ctrl);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_control_tb);

        alu_op = ALU_OP_LOAD_STORE_IMM;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_ctrl(ALU_CTRL_ADD, "Load/Store/Addi use ADD");

        alu_op = ALU_OP_BRANCH;
        check_ctrl(ALU_CTRL_SUB, "Branch uses SUB");

        alu_op = ALU_OP_R_TYPE;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_ctrl(ALU_CTRL_ADD, "R-type ADD");

        funct7 = 7'b0100000;
        check_ctrl(ALU_CTRL_SUB, "R-type SUB");

        funct3 = 3'b001;
        funct7 = 7'b0000000;
        check_ctrl(ALU_CTRL_SLL, "R-type SLL");

        funct3 = 3'b101;
        funct7 = 7'b0000000;
        check_ctrl(ALU_CTRL_SRL, "R-type SRL");

        funct7 = 7'b0100000;
        check_ctrl(ALU_CTRL_SRA, "R-type SRA");

        alu_op = ALU_OP_I_TYPE;
        funct3 = 3'b100;
        funct7 = 7'b0000000;
        check_ctrl(ALU_CTRL_XOR, "I-type XORI");

        funct3 = 3'b101;
        funct7 = 7'b0100000;
        check_ctrl(ALU_CTRL_SRA, "I-type SRAI");

        funct3 = 3'b111;
        funct7 = 7'b0000000;
        check_ctrl(ALU_CTRL_AND, "I-type ANDI");

        $display("All ALU control tests passed.");
        $finish;
    end
endmodule

module pc_unit_tb;
    logic        clk;
    logic        rst_n;
    logic        branch;
    logic        jump;
    logic        jump_reg;
    logic [2:0]  funct3;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm;
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] pc_next;
    logic        branch_taken;

    localparam logic [2:0] BR_BEQ  = 3'b000;
    localparam logic [2:0] BR_BNE  = 3'b001;
    localparam logic [2:0] BR_BLT  = 3'b100;
    localparam logic [2:0] BR_BGE  = 3'b101;
    localparam logic [2:0] BR_BLTU = 3'b110;
    localparam logic [2:0] BR_BGEU = 3'b111;

    pc_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .funct3(funct3),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .pc(pc),
        .pc_plus4(pc_plus4),
        .pc_next(pc_next),
        .branch_taken(branch_taken)
    );

    always #5 clk = ~clk;

    task automatic step_and_check_pc(
        input logic [31:0] expected_pc_plus4,
        input logic [31:0] expected_pc_next,
        input logic        expected_branch_taken,
        input logic [31:0] expected_pc_after_edge,
        input string       test_name
    );
        begin
            #1;
            if (pc_plus4 !== expected_pc_plus4 || pc_next !== expected_pc_next || branch_taken !== expected_branch_taken) begin
                $display("FAIL: %s", test_name);
                $display("  got      pc=%h pc+4=%h pc_next=%h taken=%0b", pc, pc_plus4, pc_next, branch_taken);
                $display("  expected pc+4=%h pc_next=%h taken=%0b", expected_pc_plus4, expected_pc_next, expected_branch_taken);
                $fatal(1);
            end
            @(posedge clk);
            #1;
            if (pc !== expected_pc_after_edge) begin
                $display("FAIL: %s", test_name);
                $display("  got      pc=%h", pc);
                $display("  expected pc=%h", expected_pc_after_edge);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, pc_unit_tb);

        clk = 1'b0;
        rst_n = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        jump_reg = 1'b0;
        funct3 = BR_BEQ;
        rs1_data = 32'h0000_0000;
        rs2_data = 32'h0000_0000;
        imm = 32'h0000_0000;

        #2;
        if (pc !== 32'h0000_0000) begin
            $display("FAIL: reset should force pc to zero, got %h", pc);
            $fatal(1);
        end

        rst_n = 1'b1;
        step_and_check_pc(32'h0000_0004, 32'h0000_0004, 1'b0, 32'h0000_0004, "Sequential increment after reset");

        imm = 32'd12;
        branch = 1'b1;
        funct3 = BR_BEQ;
        rs1_data = 32'd42;
        rs2_data = 32'd42;
        step_and_check_pc(32'h0000_0008, 32'h0000_0010, 1'b1, 32'h0000_0010, "BEQ taken branches to PC+imm");

        imm = 32'd8;
        branch = 1'b1;
        funct3 = BR_BNE;
        rs1_data = 32'd7;
        rs2_data = 32'd7;
        step_and_check_pc(32'h0000_0014, 32'h0000_0014, 1'b0, 32'h0000_0014, "BNE not taken falls through");

        imm = 32'd4;
        branch = 1'b1;
        funct3 = BR_BLT;
        rs1_data = 32'hFFFF_FFFB;
        rs2_data = 32'd1;
        step_and_check_pc(32'h0000_0018, 32'h0000_0018, 1'b1, 32'h0000_0018, "BLT signed compare");

        branch = 1'b0;
        jump = 1'b1;
        imm = 32'd20;
        step_and_check_pc(32'h0000_001C, 32'h0000_002C, 1'b0, 32'h0000_002C, "JAL uses PC+imm");

        jump = 1'b0;
        jump_reg = 1'b1;
        rs1_data = 32'd100;
        imm = 32'd7;
        step_and_check_pc(32'h0000_0030, 32'h0000_006A, 1'b0, 32'h0000_006A, "JALR masks LSB of target");

        rst_n = 1'b0;
        #1;
        if (pc !== 32'h0000_0000) begin
            $display("FAIL: async reset should clear pc, got %h", pc);
            $fatal(1);
        end
        $display("PASS: asynchronous reset clears PC");

        $display("All PC unit tests passed.");
        $finish;
    end
endmodule

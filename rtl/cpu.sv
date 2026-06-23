module cpu (
    input logic        clk,
    input logic        rst_n
);
    // Fetch stage
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] pc_next;
    logic        branch_taken;
    logic [31:0] instr;

    // Control
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

    // Register file
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [4:0]  rd_addr;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] rd_data_in;

    // Immediate
    logic [31:0] imm;

    // ALU
    logic [3:0]  alu_ctrl;
    logic [31:0] alu_result;
    logic        alu_zero;
    logic [31:0] alu_operand_b;

    // Data memory
    logic [31:0] mem_read_data;

    // Instances
    imem imem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .addr(pc),
        .instr(instr),
        .write_enable(1'b0),
        .wr_addr(32'd0),
        .wr_data(32'd0)
    );

    control_unit ctrl (
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

    imm_gen immgen (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    // extract fields
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];

    reg_file regfile_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data_in(rd_data_in),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    alu_control alu_ctrl_inst (
        .alu_op(alu_op),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .alu_ctrl(alu_ctrl)
    );

    // choose ALU operand B
    always_comb begin
        if (alu_src) begin
            alu_operand_b = imm;
        end else begin
            alu_operand_b = rs2_data;
        end
    end

    alu alu_inst (
        .operand_a(rs1_data),
        .operand_b(alu_operand_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    dmem dmem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .addr(alu_result),
        .write_data(rs2_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    pc_unit pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .funct3(instr[14:12]),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .pc(pc),
        .pc_plus4(pc_plus4),
        .pc_next(pc_next),
        .branch_taken(branch_taken)
    );

    // writeback selection
    always_comb begin
        unique case (result_src)
            2'b00: rd_data_in = alu_result; // ALU
            2'b01: rd_data_in = mem_read_data; // MEM
            2'b10: rd_data_in = pc_plus4; // PC+4
            2'b11: rd_data_in = imm; // IMM (LUI)
            default: rd_data_in = alu_result;
        endcase
    end
endmodule

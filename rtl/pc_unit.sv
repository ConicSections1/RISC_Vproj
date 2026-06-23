module pc_unit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        branch,
    input  logic        jump,
    input  logic        jump_reg,
    input  logic [2:0]  funct3,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm,
    output logic [31:0] pc,
    output logic [31:0] pc_plus4,
    output logic [31:0] pc_next,
    output logic        branch_taken
);
    localparam logic [2:0] BR_BEQ  = 3'b000;
    localparam logic [2:0] BR_BNE  = 3'b001;
    localparam logic [2:0] BR_BLT  = 3'b100;
    localparam logic [2:0] BR_BGE  = 3'b101;
    localparam logic [2:0] BR_BLTU = 3'b110;
    localparam logic [2:0] BR_BGEU = 3'b111;

    logic [31:0] branch_target;
    logic [31:0] jump_target;
    logic [31:0] jump_reg_target;
    logic signed [31:0] signed_rs1;
    logic signed [31:0] signed_rs2;

    assign signed_rs1 = rs1_data;
    assign signed_rs2 = rs2_data;
    assign pc_plus4   = pc + 32'd4;
    assign branch_target = pc + imm;
    assign jump_target = pc + imm;
    assign jump_reg_target = (rs1_data + imm) & 32'hFFFF_FFFE;

    always_comb begin
        branch_taken          = 1'b0;
        pc_next               = pc_plus4;

        if (branch) begin
            case (funct3)
                BR_BEQ:  branch_taken = (rs1_data == rs2_data);
                BR_BNE:  branch_taken = (rs1_data != rs2_data);
                BR_BLT:  branch_taken = (signed_rs1 < signed_rs2);
                BR_BGE:  branch_taken = (signed_rs1 >= signed_rs2);
                BR_BLTU: branch_taken = (rs1_data < rs2_data);
                BR_BGEU: branch_taken = (rs1_data >= rs2_data);
                default: branch_taken = 1'b0;
            endcase
        end

        if (branch && branch_taken) begin
            pc_next = branch_target;
        end else if (jump_reg) begin
            pc_next = jump_reg_target;
        end else if (jump) begin
            pc_next = jump_target;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= pc_next;
        end
    end
endmodule

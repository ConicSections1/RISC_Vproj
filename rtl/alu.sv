module alu (
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    input  logic [3:0]  alu_ctrl,
    output logic [31:0] result,
    output logic        zero
);
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

    logic signed [31:0] signed_operand_a;
    logic signed [31:0] signed_operand_b;
    logic [4:0]         shift_amount;

    assign shift_amount = operand_b[4:0];

    always_comb begin
        signed_operand_a = operand_a;
        signed_operand_b = operand_b;

        result = 32'h0000_0000;

        case (alu_ctrl)
            ALU_CTRL_ADD:  result = operand_a + operand_b;
            ALU_CTRL_SUB:  result = operand_a - operand_b;
            ALU_CTRL_AND:  result = operand_a & operand_b;
            ALU_CTRL_OR:   result = operand_a | operand_b;
            ALU_CTRL_XOR:  result = operand_a ^ operand_b;
            ALU_CTRL_SLT:  result = {{31{1'b0}}, (signed_operand_a < signed_operand_b)};
            ALU_CTRL_SLTU: result = {{31{1'b0}}, (operand_a < operand_b)};
            ALU_CTRL_SLL:  result = operand_a << shift_amount;
            ALU_CTRL_SRL:  result = operand_a >> shift_amount;
            ALU_CTRL_SRA:  result = signed_operand_a >>> shift_amount;
            ALU_CTRL_PASS: result = operand_b;
            default:       result = 32'h0000_0000;
        endcase
    end

    assign zero = (result == 32'h0000_0000);
endmodule

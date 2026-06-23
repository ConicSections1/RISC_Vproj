module alu_control (
    input  logic [1:0] alu_op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_ctrl
);
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

    logic funct7_is_subtract;

    assign funct7_is_subtract = funct7[5];

    always_comb begin
        alu_ctrl = ALU_CTRL_ADD;

        case (alu_op)
            ALU_OP_LOAD_STORE_IMM: alu_ctrl = ALU_CTRL_ADD;
            ALU_OP_BRANCH:         alu_ctrl = ALU_CTRL_SUB;
            ALU_OP_R_TYPE: begin
                case (funct3)
                    3'b000: alu_ctrl = (funct7_is_subtract ? ALU_CTRL_SUB : ALU_CTRL_ADD);
                    3'b001: alu_ctrl = ALU_CTRL_SLL;
                    3'b010: alu_ctrl = ALU_CTRL_SLT;
                    3'b011: alu_ctrl = ALU_CTRL_SLTU;
                    3'b100: alu_ctrl = ALU_CTRL_XOR;
                    3'b101: alu_ctrl = (funct7_is_subtract ? ALU_CTRL_SRA : ALU_CTRL_SRL);
                    3'b110: alu_ctrl = ALU_CTRL_OR;
                    3'b111: alu_ctrl = ALU_CTRL_AND;
                    default: alu_ctrl = ALU_CTRL_ADD;
                endcase
            end
            ALU_OP_I_TYPE: begin
                case (funct3)
                    3'b000: alu_ctrl = ALU_CTRL_ADD;
                    3'b010: alu_ctrl = ALU_CTRL_SLT;
                    3'b011: alu_ctrl = ALU_CTRL_SLTU;
                    3'b100: alu_ctrl = ALU_CTRL_XOR;
                    3'b110: alu_ctrl = ALU_CTRL_OR;
                    3'b111: alu_ctrl = ALU_CTRL_AND;
                    3'b001: alu_ctrl = ALU_CTRL_SLL;
                    3'b101: alu_ctrl = (funct7_is_subtract ? ALU_CTRL_SRA : ALU_CTRL_SRL);
                    default: alu_ctrl = ALU_CTRL_ADD;
                endcase
            end
            default: alu_ctrl = ALU_CTRL_ADD;
        endcase
    end
endmodule

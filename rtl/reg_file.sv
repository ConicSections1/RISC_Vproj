module reg_file (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data_in,
    input  logic        reg_write,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);
    logic [31:0] registers [31:0];
    integer      index;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (index = 0; index < 32; index = index + 1) begin
                registers[index] <= 32'h0000_0000;
            end
        end else begin
            if (reg_write && (rd_addr != 5'd0)) begin
                registers[rd_addr] <= rd_data_in;
            end
        end
    end

    always_comb begin
        rs1_data = 32'h0000_0000;
        rs2_data = 32'h0000_0000;

        if (rst_n) begin
            if (rs1_addr == 5'd0) begin
                rs1_data = 32'h0000_0000;
            end else if (reg_write && (rd_addr == rs1_addr) && (rd_addr != 5'd0)) begin
                rs1_data = rd_data_in;
            end else begin
                rs1_data = registers[rs1_addr];
            end

            if (rs2_addr == 5'd0) begin
                rs2_data = 32'h0000_0000;
            end else if (reg_write && (rd_addr == rs2_addr) && (rd_addr != 5'd0)) begin
                rs2_data = rd_data_in;
            end else begin
                rs2_data = registers[rs2_addr];
            end
        end
    end
endmodule

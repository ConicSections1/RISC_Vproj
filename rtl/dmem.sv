module dmem (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    input  logic        mem_read,
    input  logic        mem_write,
    output logic [31:0] read_data
);
    localparam int DEPTH = 1024;

    logic [31:0] mem [0:DEPTH-1];
    integer i;
    logic [9:0] addr_index;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= 32'h0000_0000;
            end
        end else begin
            if (mem_write) begin
                mem[addr_index] = write_data;
            end
        end
    end

    assign addr_index = addr[11:2];

    always_comb begin
        if (mem_read) begin
            read_data = mem[addr_index];
        end else begin
            read_data = 32'h0000_0000;
        end
    end
endmodule

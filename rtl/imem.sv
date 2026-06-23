module imem (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] addr,
    output logic [31:0] instr,

    // simple synchronous write port for simulation preload
    input  logic        write_enable,
    input  logic [31:0] wr_addr,
    input  logic [31:0] wr_data
);
    localparam int DEPTH = 1024;

    logic [31:0] mem [0:DEPTH-1];
    integer i;
    logic [9:0] addr_index;
    logic [9:0] wr_index;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= 32'h0000_0000;
            end
        end else begin
            if (write_enable) begin
                mem[wr_index] = wr_data;
            end
        end
    end

    assign addr_index = addr[11:2];
    assign wr_index   = wr_addr[11:2];
    always_comb begin
        instr = mem[addr_index];
    end
endmodule

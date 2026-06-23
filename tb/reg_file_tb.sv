module reg_file_tb;
    logic        clk;
    logic        rst_n;
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [4:0]  rd_addr;
    logic [31:0] rd_data_in;
    logic        reg_write;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    reg_file dut (
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

    always #5 clk = ~clk;

    task automatic check_read(
        input logic [31:0] expected_rs1,
        input logic [31:0] expected_rs2,
        input string       test_name
    );
        begin
            #1;
            if (rs1_data !== expected_rs1 || rs2_data !== expected_rs2) begin
                $display("FAIL: %s | expected rs1=%h rs2=%h, got rs1=%h rs2=%h", test_name, expected_rs1, expected_rs2, rs1_data, rs2_data);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, reg_file_tb);

        clk = 1'b0;
        rst_n = 1'b0;
        rs1_addr = 5'd0;
        rs2_addr = 5'd0;
        rd_addr = 5'd0;
        rd_data_in = 32'h0000_0000;
        reg_write = 1'b0;

        #12;
        rst_n = 1'b1;
        #1;
        check_read(32'h0000_0000, 32'h0000_0000, "Reset clears reads to zero");

        rs1_addr = 5'd0;
        rs2_addr = 5'd0;
        rd_addr = 5'd1;
        rd_data_in = 32'h1234_5678;
        reg_write = 1'b1;
        #1;
        check_read(32'h0000_0000, 32'h0000_0000, "X0 remains zero during write enable");
        @(posedge clk);
        #1;

        reg_write = 1'b0;
        rs1_addr = 5'd1;
        rs2_addr = 5'd0;
        #1;
        check_read(32'h1234_5678, 32'h0000_0000, "Written register reads back");

        rd_addr = 5'd2;
        rd_data_in = 32'hDEAD_BEEF;
        reg_write = 1'b1;
        rs1_addr = 5'd2;
        rs2_addr = 5'd1;
        #1;
        check_read(32'hDEAD_BEEF, 32'h1234_5678, "Same-cycle bypass on read ports");
        @(posedge clk);
        #1;

        reg_write = 1'b0;
        rs1_addr = 5'd2;
        rs2_addr = 5'd1;
        #1;
        check_read(32'hDEAD_BEEF, 32'h1234_5678, "Stored values persist after write clock");

        rst_n = 1'b0;
        #1;
        check_read(32'h0000_0000, 32'h0000_0000, "Async reset clears outputs");

        $display("All register file tests passed.");
        $finish;
    end
endmodule

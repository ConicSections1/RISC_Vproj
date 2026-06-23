module imem_tb;
    logic        clk;
    logic        rst_n;
    logic [31:0] addr;
    logic [31:0] instr;

    logic        write_enable;
    logic [31:0] wr_addr;
    logic [31:0] wr_data;

    imem dut (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .instr(instr),
        .write_enable(write_enable),
        .wr_addr(wr_addr),
        .wr_data(wr_data)
    );

    always #5 clk = ~clk;

    task automatic check_instr(
        input logic [31:0] expected_instr,
        input string test_name
    );
        begin
            #1;
            if (instr !== expected_instr) begin
                $display("FAIL: %s | expected instr=%h, got instr=%h", test_name, expected_instr, instr);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, imem_tb);

        clk = 1'b0;
        rst_n = 1'b0;
        addr = 32'h0000_0000;
        write_enable = 1'b0;
        wr_addr = 32'h0000_0000;
        wr_data = 32'h0000_0000;

        #12;
        rst_n = 1'b1;
        #1;

        // preload address 0 and 4 directly into the imem model
        dut.mem[0] = 32'hDEAD_BEEF;
        dut.mem[1] = 32'hCAFEBABE; // address 4 -> index 1

        addr = 32'd0;
        check_instr(32'hDEAD_BEEF, "IMEM read word 0");

        addr = 32'd4;
        check_instr(32'hCAFEBABE, "IMEM read word 4");

        $display("All imem tests passed.");
        $finish;
    end
endmodule

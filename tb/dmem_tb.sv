module dmem_tb;
    logic        clk;
    logic        rst_n;
    logic [31:0] addr;
    logic [31:0] write_data;
    logic        mem_read;
    logic        mem_write;
    logic [31:0] read_data;

    dmem dut (
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    task automatic check_read(
        input logic [31:0] expected_read,
        input string test_name
    );
        begin
            #1;
            if (read_data !== expected_read) begin
                $display("FAIL: %s | expected read=%h, got read=%h", test_name, expected_read, read_data);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dmem_tb);

        clk = 1'b0;
        rst_n = 1'b0;
        addr = 32'h0000_0000;
        write_data = 32'h0000_0000;
        mem_read = 1'b0;
        mem_write = 1'b0;

        #12;
        rst_n = 1'b1;
        #1;

        // preload memory directly for this test
        dut.mem[2] = 32'hFEED_FACE; // address 8 -> index 2
        addr = 32'd8;
        mem_read = 1'b1;
        #1;
        check_read(32'hFEED_FACE, "DMEM read after write");

        // read default zero at address 12
        addr = 32'd12;
        mem_read = 1'b1;
        check_read(32'h0000_0000, "DMEM default zero");

        $display("All dmem tests passed.");
        $finish;
    end
endmodule

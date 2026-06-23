module cpu_tb;
    logic clk;
    logic rst_n;
    localparam int PROGRAM_WORDS = 5;

    cpu dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    task automatic check_reg(
        input int regnum,
        input logic [31:0] expected,
        input string test_name
    );
        begin
            #1;
            if (dut.regfile_inst.registers[regnum] !== expected) begin
                $display("FAIL: %s | reg[%0d]=%h expected=%h", test_name, regnum, dut.regfile_inst.registers[regnum], expected);
                $fatal(1);
            end
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, cpu_tb);

        clk = 1'b0;
        rst_n = 1'b0;

        #12;
        rst_n = 1'b1;

        // Load program into instruction memory from sim/program.mem.
        // One 32-bit word per line, MSB-first.
        $display("Attempting to load program from sim/program.mem");
        $readmemh("program.mem", dut.imem_inst.mem, 0, PROGRAM_WORDS - 1);

        // run enough cycles to execute the program
        repeat (12) begin
            @(posedge clk);
        end

        // check that x4 == 15 (10 + 5)
        check_reg(4, 32'd15, "Load after store returns sum");

        $display("All CPU integration smoke tests passed.");
        $finish;
    end
endmodule

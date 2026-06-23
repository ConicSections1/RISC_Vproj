module cpu_trace_tb;
    logic clk;
    logic rst_n;
    integer trace_fd;
    integer cycle;
    localparam int PROGRAM_WORDS = 5;

    cpu dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    task automatic write_trace_line;
        begin
            #1;
            $fwrite(trace_fd, "%0d,%0t,%h,%h,%h,%h,%h,%h,%h,%h,%h\n",
                cycle,
                $time,
                dut.pc,
                dut.instr,
                dut.alu_result,
                dut.branch_taken,
                dut.regfile_inst.registers[1],
                dut.regfile_inst.registers[2],
                dut.regfile_inst.registers[3],
                dut.regfile_inst.registers[4],
                dut.pc_next
            );
        end
    endtask

    initial begin
        $dumpfile("cpu_trace.vcd");
        $dumpvars(0, cpu_trace_tb);

        trace_fd = $fopen("cpu_trace.csv", "w");
        if (trace_fd == 0) begin
            $fatal(1, "Unable to open cpu_trace.csv");
        end
        $fwrite(trace_fd, "cycle,time,pc,instr,alu_result,branch_taken,x1,x2,x3,x4,pc_next\n");

        clk = 1'b0;
        rst_n = 1'b0;
        cycle = 0;

        #12;
        rst_n = 1'b1;

        $readmemh("program.mem", dut.imem_inst.mem, 0, PROGRAM_WORDS - 1);

        repeat (12) begin
            @(posedge clk);
            cycle = cycle + 1;
            write_trace_line();
        end

        $fclose(trace_fd);
        $finish;
    end
endmodule

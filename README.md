RISC-V RV32I Single-Cycle CPU

Overview
- This repository contains a 32-bit RISC-V RV32I single-cycle CPU written in SystemVerilog.
- The goal is to present the design as an engineering portfolio piece: the RTL is reproducible, the testbench is deterministic, and the documentation includes visual proof of operation.
- RTL lives in `rtl/`, testbenches in `tb/`, reusable simulation inputs live in `sim/`, and presentation assets live in `docs/assets/`.

Design Summary
- `rtl/alu.sv` and `rtl/alu_control.sv`: arithmetic and operation decoding.
- `rtl/reg_file.sv`: 32x32 register file with two read ports and one write port, with `x0` hardwired to zero.
- `rtl/imm_gen.sv`: RV32I immediate generator for I/S/B/U/J formats.
- `rtl/control_unit.sv`: main opcode decoder and control-signal generator.
- `rtl/pc_unit.sv`: program counter update and branch/jump target selection.
- `rtl/imem.sv` and `rtl/dmem.sv`: simple Harvard memory models for simulation.
- `rtl/cpu.sv`: top-level single-cycle integration of the full datapath.

Visual Proof of Operation
- `docs/assets/cpu_waveform.png` shows a reproducible CPU trace derived from the simulator output.
- `docs/assets/cpu_datapath.png` shows the high-level single-cycle datapath used to build the design.
- The CPU is a single-cycle core, so there are no pipeline registers or forwarding paths to display.
- If you want to inspect the raw trace interactively, run the trace testbench and open `sim/cpu_trace.vcd` in GTKWave.

How to Reproduce
If you need the Python plotting stack, install the documented dependencies first:

```bash
python3 -m pip install -r docs/requirements.txt
```

From the project root, generate the trace and assets:

```bash
python3 docs/generate_cpu_assets.py
```

Then run the integration test directly:

```bash
cd sim
iverilog -g2012 -o cpu_tb.out ../rtl/*.sv ../tb/cpu_tb.sv
vvp cpu_tb.out
```

To generate the trace for GTKWave or the waveform image, run the trace testbench:

```bash
cd sim
iverilog -g2012 -o cpu_trace_tb.out ../rtl/*.sv ../tb/cpu_trace_tb.sv
vvp cpu_trace_tb.out
```

The CPU trace testbench writes `cpu_trace.csv` and `cpu_trace.vcd` into `sim/`, then the asset generator converts the CSV trace into `docs/assets/cpu_waveform.png`.

Program Input
- Edit `sim/program.mem` to change the loaded instruction sequence.
- Each line should contain one 32-bit instruction word in hex.
- The current demo program computes a simple sum, stores it to memory, and loads it back into `x4`.

Documentation Artifacts
- `docs/generate_cpu_assets.py`: regenerates the published CPU images.
- `docs/assets/cpu_waveform.png`: proof-of-operation trace image.
- `docs/assets/cpu_datapath.png`: block diagram of the CPU datapath.

Coding Guidelines Followed
- SystemVerilog (IEEE 1800-2012)
- Explicit port mapping everywhere
- `always_comb` for combinational logic, `always_ff @(posedge clk or negedge rst_n)` for sequential logic
- Active-low asynchronous resets (`rst_n`)
- `logic` types throughout
- `localparam` used for opcode and ALU control values

Notes
- The project uses deterministic testbenches and reproducible simulation inputs so the results can be regenerated from source.
- Some `unique` case qualities are present in RTL; Icarus Verilog treats them as normal cases during simulation.

Next steps
- Add a small assembler or loader to translate assembly to `program.mem` automatically.
- Add more comprehensive ISA compliance tests.
- Add CI to regenerate the documentation assets and run the simulator tests automatically.


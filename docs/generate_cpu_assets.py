#!/usr/bin/env python3
"""Generate CPU portfolio assets: a waveform proof image and a datapath block diagram.

Run from the repository root or any location; output is written to docs/assets/.
"""

from __future__ import annotations

import csv
import subprocess
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

ROOT = Path(__file__).resolve().parents[1]
SIM_DIR = ROOT / "sim"
TB_DIR = ROOT / "tb"
ASSETS_DIR = ROOT / "docs" / "assets"
TRACE_CSV = SIM_DIR / "cpu_trace.csv"
TRACE_VCD = SIM_DIR / "cpu_trace.vcd"
TRACE_OUT = SIM_DIR / "cpu_trace_tb.out"


def run_trace_sim() -> None:
    rtl_files = sorted(str(path) for path in (ROOT / "rtl").glob("*.sv"))
    subprocess.run(
        ["iverilog", "-g2012", "-o", TRACE_OUT.name, *[f"../rtl/{Path(path).name}" for path in rtl_files], "../tb/cpu_trace_tb.sv"],
        cwd=SIM_DIR,
        check=True,
    )
    subprocess.run(["vvp", TRACE_OUT.name], cwd=SIM_DIR, check=True)


def _read_trace():
    rows = []
    with TRACE_CSV.open(newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            rows.append(row)
    return rows


def _to_int(value: str) -> int:
    return int(value, 16)


def plot_waveform(rows) -> None:
    cycles = [int(row["cycle"]) for row in rows]
    pc = [_to_int(row["pc"]) for row in rows]
    alu_result = [_to_int(row["alu_result"]) for row in rows]
    x1 = [_to_int(row["x1"]) for row in rows]
    x2 = [_to_int(row["x2"]) for row in rows]
    x3 = [_to_int(row["x3"]) for row in rows]
    x4 = [_to_int(row["x4"]) for row in rows]
    branch_taken = [int(row["branch_taken"], 16) for row in rows]

    plt.style.use("seaborn-v0_8-darkgrid")
    fig, (ax0, ax1) = plt.subplots(
        2,
        1,
        figsize=(12, 7),
        sharex=True,
        gridspec_kw={"height_ratios": [2, 1]},
    )

    ax0.step(cycles, pc, where="post", label="PC", linewidth=2.2)
    ax0.step(cycles, alu_result, where="post", label="ALU result", linewidth=2.0)
    ax0.set_ylabel("Hex value")
    ax0.set_title("CPU proof of operation from simulator trace")
    ax0.legend(loc="upper left", ncol=2)
    ax0.grid(True, alpha=0.3)

    ax1.step(cycles, x1, where="post", label="x1", linewidth=2.0)
    ax1.step(cycles, x2, where="post", label="x2", linewidth=2.0)
    ax1.step(cycles, x3, where="post", label="x3", linewidth=2.0)
    ax1.step(cycles, x4, where="post", label="x4", linewidth=2.2)
    ax1.step(cycles, branch_taken, where="post", label="branch_taken", linewidth=1.8)
    ax1.set_xlabel("Cycle")
    ax1.set_ylabel("Value")
    ax1.legend(loc="upper left", ncol=5, fontsize=9)
    ax1.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig(ASSETS_DIR / "cpu_waveform.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def _box(ax, x, y, w, h, text, fontsize=10):
    patch = FancyBboxPatch(
        (x, y),
        w,
        h,
        boxstyle="round,pad=0.02,rounding_size=0.04",
        linewidth=1.8,
        edgecolor="#1f2937",
        facecolor="#eef2ff",
    )
    ax.add_patch(patch)
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=fontsize, weight="bold")


def _arrow(ax, start, end, text=None, text_offset=(0, 0)):
    arrow = FancyArrowPatch(start, end, arrowstyle="->", mutation_scale=16, linewidth=1.6, color="#111827")
    ax.add_patch(arrow)
    if text:
        ax.text((start[0] + end[0]) / 2 + text_offset[0], (start[1] + end[1]) / 2 + text_offset[1], text, fontsize=9, color="#374151")


def plot_block_diagram() -> None:
    fig, ax = plt.subplots(figsize=(15, 7))
    ax.set_xlim(0, 15)
    ax.set_ylim(0, 8)
    ax.axis("off")

    ax.text(7.5, 7.5, "RV32I Single-Cycle CPU Datapath", ha="center", va="center", fontsize=18, weight="bold")

    _box(ax, 0.6, 5.2, 1.4, 0.9, "PC")
    _box(ax, 2.4, 5.0, 1.8, 1.2, "Instruction\nMemory")
    _box(ax, 4.6, 5.0, 1.8, 1.2, "Control\nUnit")
    _box(ax, 7.0, 5.0, 1.7, 1.2, "Register\nFile")
    _box(ax, 9.2, 5.0, 1.8, 1.2, "Imm\nGen")
    _box(ax, 11.5, 5.0, 1.5, 1.2, "ALU\nCtrl")
    _box(ax, 13.4, 5.0, 1.0, 1.2, "ALU")

    _box(ax, 9.0, 2.0, 2.0, 1.1, "Data\nMemory")
    _box(ax, 11.8, 2.0, 1.9, 1.1, "Writeback\nMux")
    _box(ax, 0.9, 2.0, 2.1, 1.1, "Next-PC\nLogic")

    _arrow(ax, (2.0, 5.65), (2.4, 5.65), "pc")
    _arrow(ax, (4.2, 5.6), (4.6, 5.6), "instr")
    _arrow(ax, (6.4, 5.55), (7.0, 5.55), "rs1/rs2/rd")
    _arrow(ax, (8.7, 5.55), (9.2, 5.55), "imm")
    _arrow(ax, (10.9, 5.55), (11.5, 5.55), "funct3/7")
    _arrow(ax, (13.0, 5.55), (13.4, 5.55), "alu_op")

    _arrow(ax, (14.4, 5.0), (12.8, 3.1), "ALU addr")
    _arrow(ax, (13.4, 3.1), (11.8, 2.55), "read_data")
    _arrow(ax, (11.8, 2.55), (8.0, 5.25), "wb_data")

    _arrow(ax, (1.3, 5.2), (1.3, 3.1), "pc_next")
    _arrow(ax, (2.0, 2.55), (0.6, 5.2), "branch/jump")
    _arrow(ax, (8.0, 5.0), (9.9, 3.1), "addr/write")
    _arrow(ax, (8.4, 5.1), (10.9, 5.1), "src select")

    ax.text(
        7.5,
        0.6,
        "Single-cycle flow: fetch -> decode -> execute -> memory -> writeback in one clock cycle",
        ha="center",
        fontsize=11,
        color="#374151",
    )

    fig.tight_layout()
    fig.savefig(ASSETS_DIR / "cpu_datapath.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    run_trace_sim()
    rows = _read_trace()
    plot_waveform(rows)
    plot_block_diagram()
    print(f"Generated assets in {ASSETS_DIR}")


if __name__ == "__main__":
    main()

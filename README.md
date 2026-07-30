# 16-Bit ALU Design & SystemVerilog Verification Environment

A complete RTL implementation and self-checking verification environment for a **16-bit Arithmetic Logic Unit (ALU)** written in **Verilog HDL** and **SystemVerilog**.

The project demonstrates both digital design and verification concepts by implementing a golden reference model, randomized stimulus generation, automated checking, and waveform-based debugging.

---

## Features

### RTL Design

- 16-bit ALU

#### Arithmetic Operations
- Addition
- Subtraction
- Multiplication
- Division

#### Logic Operations
- AND
- OR
- NAND
- NOR
- XOR
- XNOR

#### Comparison Operations
- Equal
- Greater Than
- Less Than

#### Shift Operations
- Logical Right Shift
- Logical Left Shift

### Status Flags

- Arithmetic Flag
- Carry Flag
- Logic Flag
- Comparison Flag
- Shift Flag

---

## Verification Environment

The SystemVerilog testbench includes:

- Random stimulus generation
- Driver
- Monitor
- Golden Reference Model (Predictor)
- Self-Checking Scoreboard
- Pass/Fail Reporting
- Functional Verification of all ALU operations

The verification flow compares the DUT outputs against a software-computed golden model and automatically reports any mismatches.

---

## Project Files

| File | Description |
|------|-------------|
| `DUT.V` | 16-bit ALU RTL implementation |
| `DUT_TB.SV` | Self-checking SystemVerilog testbench |
| `run.do` | QuestaSim automation script |

---

## Simulation

Designed and verified using **Siemens QuestaSim**.

Run the simulation using:

```tcl
do run.do
```

---

## Learning Objectives

This project demonstrates:

- Verilog RTL Design
- Combinational Logic Design
- SystemVerilog Testbench Development
- Task-Based Verification
- Randomized Testing
- Golden Reference Modeling
- Self-Checking Verification
- Waveform Debugging

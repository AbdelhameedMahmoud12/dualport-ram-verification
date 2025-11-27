# dualport-ram-verification

A complete SystemVerilog, UVM, and Formal verification environment for a parameterizable **True Dual-Port SRAM (dp_ram)**.  
This repository verifies the functional correctness, collision behavior, and protocol compliance of the dp_ram module as defined in the official functional specification.

---

## 📌 1. Overview

The `dp_ram` is a parameterizable **True Dual-Port Static RAM** supporting simultaneous read/write access from two independent ports (Port A and Port B).  
This environment provides comprehensive verification across:

- Pure SystemVerilog Testbench  
- UVM Environment  
- SystemVerilog Assertions (SVA)  
- Formal Verification (Property Checking)

The goal is to fully validate all spec-defined behaviors, including timing, reset logic, pipelined outputs, and collision handling.

---

## 📐 2. DUT Specifications

### **Main Features**
- True Dual-Port SRAM (TDP)
- Independent access on Port A & Port B
- `DATA_WIDTH` and `DEPTH` are fully configurable  
- Synchronous, active-high reset  
- Registered 1-cycle read latency  
- Collision protection with defined priority  
- **Read-First architecture**  
- Port A has **priority** during write/write clashes  

### **Interface Summary**

#### **Clock & Reset**
| Signal | Dir | Description |
|--------|-----|-------------|
| `clk` | Input | Rising-edge system clock |
| `reset` | Input | Active-high synchronous reset (clears output regs only) |

#### **Port A** *(Port B identical with suffix `_b`)*  
| Signal | Dir | Description |
|--------|-----|-------------|
| `enable_a` | Input | Enables operations |
| `write_enable_a` | Input | 1 = Write, 0 = Read |
| `address_a` | Input | Address (`$clog2(DEPTH)`) |
| `write_data_a` | Input | Data to write |
| `read_valid_a` | Output | 1-cycle delayed read-valid |
| `read_data_a` | Output | Registered read data |

---

## ⚙️ 3. Functional Behavior Summary

### **Reset**
- `read_data_*` → 0  
- `read_valid_*` → 0  
- Memory array contents **not cleared** (BRAM inference requirement)

### **Read Operation**
- Initiated when: `enable=1` and `wen=0`
- Latency: **1 cycle** (registered)
- `read_valid` asserted exactly one cycle after request

### **Write Operation**
- Initiated when: `enable=1` and `wen=1`
- Writes update memory on the same clock edge
- Outputs do not return the new data in the same cycle

### **Collision Handling**
| Type | Behavior |
|------|----------|
| Read / Read | Both ports read normally |
| Read / Write | **Read-First**: read returns *old* data |
| Write / Write | **Port A priority** – only A writes, B is ignored |

---

## 🧪 4. Verification Goals

All spec requirements REQ-MEM-001 → REQ-MEM-006 must be fully verified.

### **Key Requirements**
- Independent dual-port operation  
- Reset behavior compliance  
- Read latency = 1 cycle  
- read_valid protocol correctness  
- Correct Read-First behavior in hazards  
- Correct priority during write/write collisions  

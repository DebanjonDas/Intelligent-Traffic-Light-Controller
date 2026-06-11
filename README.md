# 🚦 Intelligent Traffic Light Controller

An adaptive, modular digital hardware system designed and verified using **Verilog HDL**. This controller replaces primitive fixed-timer systems with dynamic, real-time sensing capabilities—incorporating adaptive traffic density timing, emergency vehicle routing, pedestrian handling, and an energy-efficient night mode.

---

## 📌 Project Overview
The goal of this project is to model an optimized, production-ready traffic management hub using a hierarchical structural architecture. The system actively processes road conditions (sensor data) to maximize traffic throughput and minimize intersection wait times.

### Key Features
* 📊 **Density-Based Timing:** Dynamically calculates green light intervals ($10\text{s}$ to $60\text{s}$) based on actual vehicle queues.
* 🚑 **Emergency Vehicle Priority:** Automatically overrides standard cycles to open corridors for emergency vehicles, resolving simultaneous requests by checking queue density.
* 🚶 **Pedestrian Crossing System:** Latches pedestrian requests via a dedicated latch controller, inserting a safe walking phase (`PED_WALK`) at the end of the full cycle.
* 🌙 **Night Mode Operation:** Suspends normal state sequencing to flash warning yellow signals on all routes via a structural hardware clock divider.
* ⚡ **Rigorous Functional Verification:** Validated through an extensive testbench covering overlapping asynchronous event triggers.

---

## 🏗️ Hardware Architecture & System Topology

The design utilizes a **hierarchical and modular approach**, dividing tasks among specialized compute blocks and an isolated Finite State Machine (FSM) control engine.

```text
               +-------------------------------------------------+
               |          INTELLIGENT TRAFFIC CONTROLLER         |
               +-------------------------------------------------+
                     ^              ^               ^       
                     |              |               |       
       +-------------+---+    +-----+-----+   +-----+-----------+
       |Density Processor|    | Emergency |   |  Pedestrian     |
       |    (Compute)    |    | Arbitrator|   | Latch Controller|
       +-------------+---+    +-----+-----+   +-----+-----------+
                     |              |               |
                     v              v               v
               +-------------------------------------------------+
               |              Central Control FSM                |
               +-------------------+-----------------------------+
                                   |
                     +-------------+-------------+
                     |                           |
                     v                           v
           +-------------------+       +-------------------+
           |    Timer Core     |       |    Light Output   |
           | (Hardware Counter)|       |   Decoder (LEDs)  |
           +-------------------+       +-------------------+

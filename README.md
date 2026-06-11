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
### Module Breakdown
* **`intelligent_traffic_controller`**: The top-level wrapper managing internal net routing and structural module instantiations.
* **`Traffic_fsm`**: The central controller governing state transitions based on timer statuses, emergency flags, and mode inputs.
* **`timer`**: A hardware countdown block handling precise delay generation based on dynamically injected durations.
* **`density_processor`**: A combinational look-up matrix that maps calculated vehicle counts to optimal phase delays.
* **`emergency`**: A prioritize-and-route matrix dealing with active emergency overrides and density arbitration.
* **`pedestrian_controller`**: A sequential event-catcher ensuring pedestrian requests are latched and safely retained until serviced.
* **`light_output_decoder`**: Maps current state vectors directly to standard driver signals while incorporating an active pulse-width toggled blink routine for low-power operation.

---

## 🚦 Finite State Machine (FSM) Specification

The engine relies on a robust Moore-type FSM containing 9 structural operational states.

```text
               ┌───────────┐         ┌───────────┐
      ┌───────►│   NIGHT   │         │ EMERGENCY │◄──────┐
      │        └───────────┘         └───────────┘       │
  night_mode=1                             emergency_present=1
      │                                                  │
      │         ┌───────┐     ┌───────┐     ┌─────────┐  │
      └─────────┤ NS_G  ├────►│ NS_Y  ├────►│ ALL_R1  ├──┴──┐
                └▲──────┘     └───────┘     └────┬────┘     │
                 │                               │          │
           No Ped Request                        ▼          │
                 │                          ┌────┴────┐     │
                 │                          │  EW_G   │     │
                 │                          └────┬────┘     │
                 │                               │          │
                 │            ┌───────┐     ┌────▼────┐     │
                 └────────────┤ALL_R2 │◄────┤  EW_Y   │     │
                              └───┬───┘     └─────────┘     │
                                  │                         │
                             Ped Request=1                  │
                                  ▼                         │
                             ┌────────┐                     │
                             │PED_WALK│◄────────────────────┘
                             └────────┘

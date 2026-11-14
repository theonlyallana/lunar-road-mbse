# Lunar Road Demo: SysML v2 model

A model-based systems engineering (MBSE) model of the Lunar Road Demo: a simulation that compares the same VIPER-class rover trip at the lunar south pole with and without a road, plus a 1:10 tabletop rover that replays the results.

The model is written in SysML v2 textual notation. It traces from mission need to requirements, to architecture, to verification. Every value comes from the project specs, which cite public NASA and supplier sources. VIPER details are a public-source reconstruction, not NASA's design.

**Validated:** all nine model files parse and validate with zero errors and zero warnings on the SysML v2 Pilot Implementation 0.63.1 (release 2026-09.1).

## Diagrams

Rendered from the model by the Pilot Implementation.

| Logical architecture (IF-03 to IF-07) | Rover operating modes |
|---|---|
| ![Logical architecture](diagrams/systemArchitecture.svg) | ![Rover operating modes](diagrams/roverModes.svg) |

| 1:10 rover electrical design (E1 to E5) | One simulation run |
|---|---|
| ![Rover electrical design](diagrams/roverElectrical.svg) | ![Simulation run](diagrams/runFlow.svg) |

More in [`diagrams/`](diagrams): system context, part tree and road preset variants. The requirements are best read as a table: [`traceability.csv`](traceability.csv) lists all 71 with their wording, rationale, source and check.

## What's in the model

| File | Contents |
|---|---|
| `00_Metadata.sysml` | Project metadata on every requirement: where it comes from in the specs, and whether it was kept, reworded, split or added. |
| `01_Structure.sysml` | Logical architecture: environment, planner, command delay link, rover (mobility and power), display, scenario config. Items, ports and interface definitions IF-01 to IF-07, all connected. |
| `02_Context_UseCases.sysml` | Actors (viewer, lunar terrain, ephemeris) and use cases. |
| `03_Requirements_Sim.sysml` | 52 simulation and presentation requirements, one "shall" each, with rationale and source metadata. Three modelling assumptions (ASM-P1, ASM-E2, ASM-C1) are recorded as `assume constraint`s rather than requirements. |
| `04_Behaviour.sysml` | Functional flow of one run, a road versus no-road comparison, and the rover operating mode state machine (awaiting command, driving, holding, waiting for Earth, arrived, failed). |
| `05_RoadPresets_Variants.sysml` | Variability: four road presets and three awake-load presets, with two example configurations from the 24-run stored set. |
| `06_Hardware_1to10.sysml` | Physical architecture of the 1:10 rover (Pico 2 W, DRV8833 drivers, four encoded gearmotors, IMU, LEDs, NiMH battery), connections E1 to E6 including encoder feedback and battery sensing, VIPER reference blocks, and allocations matching the spec's VIPER-to-tabletop table. |
| `07_Requirements_Hardware.sysml` | 19 rover and rover-presentation requirements (REQ-H1 to H12), with rationale and source metadata. |
| `08_Verification_Traceability.sysml` | 19 verification cases with methods (test, analyse, inspect, demo), satisfy relations for the simulation, the rover and the presentation, and allocation of run steps to logical elements. |
| `traceability.csv` | Requirement to verification matrix, generated from the model: ID, wording, rationale, source, basis, TBR status, check and method. |
| `diagrams/` | Seven diagrams rendered from the model (SVG). |
| `notebooks/LunarRoadDemo.ipynb` | Loads every file in order and renders the diagrams. |

## Key modelling decisions

- **Requirements written to INCOSE rules.** Each requirement has one "shall", is verifiable, and carries rationale and source. Compound spec requirements were split and keep their parent ID with a decimal suffix (REQ-C2 became C2.1 to C2.6), so every original ID still traces. Of the 71: 37 were split from compound ones, 15 are reworded to be checkable, 16 are new, and 3 keep the spec's words exactly. The new ones close gaps found in review: repeatability, the road-on minus road-off difference, interfaces, command acknowledgement, and the power and shadow pass tolerances. Sixteen are marked TBR (to be reviewed): proposed values, definitions or formats. They include raising the command resend timeout from 10 s to 15 s, because a 10 s timeout equals the maximum round trip and would resend every command. Statements about how the model works became modelling assumptions, and presentation rules (caveats, how R2 is described) apply to a separate presentation element, not the simulation.
- **Sourced versus assumed values.** Sourced values (447 kg mass, 15° slope limit, 5,420 Wh battery, 6 to 10 s round trip) are bound with `=`. Assumed values (250 W awake load, 20% reserve, every road preset value, packet drops) use `default`, so they stay configurable, as the spec requires (REQ-MVP4). Derived values are marked as derived.
- **The road changes only road flags.** Both runs share one rover, planner and environment. The road presets are variants, not structural changes (REQ-E3).
- **The physical rover reuses the simulation interfaces.** Its Wi-Fi link carries the IF-04 and IF-05 message fields, with battery voltage in place of state of charge, so the hardware places no new requirement on the simulation.
- **Allocation, not copying.** VIPER blocks are allocated to tabletop stand-ins (for example IAU and SEPIA to the Pico 2 W). That makes the gap between the model and VIPER explicit.

## Verification coverage

All 71 requirements are verified by at least one case. The hardware checks CK-H1 to CK-H8 follow the spec's own "Covers" column. The simulation spec's checks CK-1 to CK-5 do not say which requirements they cover, so every simulation mapping is this model's judgement, and each check verifies only what its pass condition actually tests. Six checks are **proposed additions**, marked PROPOSED in their names: CK-6 (planner, power and delay unit tests), CK-7 (presentation review), CK-8 (outputs and configuration review), CK-9 (interface inspection), CK-H9 (caveat check) and CK-H10 (charging check). CK-H3's pass range is 45.5 to 55.5 s, inside REQ-H4's ±10%.

None of the hardware checks has been run yet, because the rover is not built.

## How to run it

1. Install Java 21+ and Miniconda.
2. Download the SysML v2 Jupyter kernel from the [SysML v2 Pilot Implementation releases](https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation/releases) and run its `install.sh` (or `install.bat`).
3. Run `jupyter lab`, open `notebooks/LunarRoadDemo.ipynb`, and run all cells.

You can also import the `.sysml` files into [SysON](https://mbse-syson.org) for graphical editing.

To regenerate the traceability matrix after editing: `python3 tools/trace.py model/`

To regenerate the diagrams with Java 21 and a recent Graphviz (2.43 fails on interconnection views): `java -cp jupyter-sysml-kernel-0.63.1-all.jar tools/RenderDiagrams.java <sysml.library> diagrams/`, with `GRAPHVIZ_DOT` pointing at `dot`.

## Next steps

- A power trade study as an `analysis def`, using results from the space-power-sims project.
- Link CK-3 and CK-4 to actual simulation outputs as verification evidence.
- A Mars variant (no long lunar night, dust storms, longer comms delay), using SysML v2 variation.

## Sources

The model is derived from three project documents: *Lunar Road Demo MVP: System Boundary and Simulation Conditions*, *VIPER Electrical Architecture Reconstruction*, and *Lunar Road Demo: 1:10 VIPER-Look Rover Hardware Design*. Their NASA and supplier sources are listed in those documents.

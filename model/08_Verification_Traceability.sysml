package LRD_Verification {
    doc /*
     * Verification cases (CK-1 to CK-5 for the simulation, CK-H1 to CK-H8 for the rover),
     * satisfy relations, and allocation of functions to logical elements.
     * None of the hardware checks has been run yet, because nothing is built.
     */

    private import VerificationCases::*;
    private import VerificationMethodKind::*;
    public import LRD_Requirements_Sim::*;
    public import LRD_Requirements_Hardware::*;
    public import LRD_Behaviour::*;

    // =====================================================================
    // Design configurations that the requirements are placed on
    // =====================================================================

    part mvpDesign : LunarRoadDemoSystem {
        part :>> rover {
            exhibit state modes : RoverModes;
        }
    }

    part roverBuild : TabletopRover;

    satisfy simulationSpecification by mvpDesign;
    satisfy hardwareSpecification by roverBuild;

    // =====================================================================
    // Allocation: which logical element performs each step of a run
    // =====================================================================

    action runScenario : RunScenario;

    allocate runScenario.computeMaps to mvpDesign.environment;
    allocate runScenario.planRoute to mvpDesign.planner;
    allocate runScenario.delayCommand to mvpDesign.commLink;
    allocate runScenario.driveAndUpdatePower to mvpDesign.rover;
    allocate runScenario.logResults to mvpDesign.display;

    // =====================================================================
    // Simulation checks (MVP spec, "MVP checks")
    // =====================================================================

    verification def 'CK-1 FairAndRepeatable' {
        doc /* Pass: both runs differ only by the road setting, and the same seed gives the same result. */
        @VerificationMethod { kind = test; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify roadOnlyChangesFlags;
            verify comparison;
        }
    }

    verification def 'CK-2 LimitsRespected' {
        doc /* Pass: no route enters a cell above 15 degrees or drives without Earth in view. */
        @VerificationMethod { kind = (test, analyze); }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify slopeLimit;
            verify hardLimits;
            verify commandHandshake;
        }
    }

    verification def 'CK-3 PowerModelCorrect' {
        doc /* Pass: Sun on a rear corner gives about 450 W, and a 600 W test load drains a full
             * battery in about 9 h. The second check tests code only. */
        @VerificationMethod { kind = analyze; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify loadModel;
            verify chargeBounds;
            verify headingForSun;
        }
    }

    verification def 'CK-4 ShadowsBelievable' {
        doc /* Pass: shadows come from terrain, and most shadow-edge speeds fall within the
             * published 0.1 to 1.8 cm/s. */
        @VerificationMethod { kind = analyze; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify visibilityFromTerrain;
            verify visibilityHeights;
        }
    }

    verification def 'CK-5 DemoWorksEndToEnd' {
        doc /* Pass: a viewer can change every control and see route, charge, shadow and results
             * update from the stored run set. */
        @VerificationMethod { kind = demo; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify reportEitherWay;
            verify caveat;
        }
    }

    // Requirements not yet covered by a CK check: REQ-M1, REQ-C1, REQ-R1, REQ-R3, REQ-R4.
    // Proposed extra check, not in the original spec:
    verification def 'CK-6 PlannerAndDelayUnitTests' {
        doc /* Proposed: unit tests that the planner uses the active preset on road cells,
             * samples delay from 6 to 10 s, applies the energy penalty and finishes each plan
             * within 5 min. */
        @VerificationMethod { kind = test; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify roadSpeedAndSlip;
            verify delaySampling;
            verify timeAndEnergy;
            verify arrivalObjective;
            verify planTime;
        }
    }

    // =====================================================================
    // Hardware checks (1:10 rover spec, "Checks")
    // =====================================================================

    verification def 'CK-H1 MeasureFinishedRover' {
        doc /* Pass: 170 x 170 mm footprint and 50 x 20 mm wheels within 2 mm; all features present. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective { verify footprintAndWheels; verify viperFeatures; }
    }

    verification def 'CK-H2 PrintEveryPart' {
        doc /* Pass: each part prints on a 180 mm bed without supports. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective { verify printable; }
    }

    verification def 'CK-H3 LevelSpeedRun' {
        doc /* Drive 1 m at a commanded 2 cm/s on level ground. Pass: takes 46 to 55 s. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective { verify levelSpeed; }
    }

    verification def 'CK-H4 RampAndTurn' {
        doc /* Drive up a 15 degree ramp of the demo surface, then turn 360 degrees on the level.
             * Pass: climbs without stalling and completes the turn. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective { verify slopeAndTurn; }
    }

    verification def 'CK-H5 EnduranceRun' {
        doc /* Drive continuously from freshly charged cells. Pass: still driving after 2 h. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective { verify endurance; }
    }

    verification def 'CK-H6 WaypointsAndCommsLoss' {
        doc /* Send five waypoints over Wi-Fi, then stop sending. Pass: status messages return and
             * the rover stops within 1 s of the last message. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective { verify wifiCommanding; verify safeStop; }
    }

    verification def 'CK-H7 TotalReceipts' {
        doc /* Pass: under GBP 300. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective { verify cost; }
    }

    verification def 'CK-H8 WeighRover' {
        doc /* Pass: under 0.8 kg. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective { verify massLimit; }
    }
}

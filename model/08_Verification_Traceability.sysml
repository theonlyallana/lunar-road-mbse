package LRD_Verification {
    doc /*
     * Verification cases (CK-1 to CK-5 for the simulation and CK-H1 to CK-H8 for the rover,
     * from the specs, plus the proposed CK-6, CK-7 and CK-H9),
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
    // Simulation checks (MVP spec, "MVP checks"). The spec does not say which
    // requirements each check covers, so these mappings are this model's judgement:
    // each check verifies only what its pass condition actually tests.
    // =====================================================================

    verification def 'CK-1 FairAndRepeatable' {
        doc /* Pass: both runs differ only by the road setting, and the same seed gives the same result. */
        @VerificationMethod { kind = test; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify roadOnlyChangesFlags;
            verify fixedScenario;
        }
    }

    verification def 'CK-2 LimitsRespected' {
        doc /* Pass: no route enters a cell above 15 degrees or drives without Earth in view.
             * Covers the slope and Earth parts of REQ-R2 and REQ-C2 only; the reserve limit,
             * resends and logging are covered by CK-6. */
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
        @VerificationMethod { kind = (analyze, test); }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify loadModel;
            verify chargeBounds;
        }
    }

    verification def 'CK-4 ShadowsBelievable' {
        doc /* Pass: shadows come from terrain, and most shadow-edge speeds fall within the
             * published 0.1 to 1.8 cm/s. */
        @VerificationMethod { kind = analyze; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify visibilityFromTerrain;
            verify widerTerrainForShadows;
        }
    }

    verification def 'CK-5 DemoWorksEndToEnd' {
        doc /* Pass: a viewer can change every control and see route, charge, shadow and results
             * update from the stored run set. */
        @VerificationMethod { kind = demo; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify precomputedRunSet;
        }
    }

    // Checks CK-6 and CK-7 are proposed by this model, not in the original spec.
    // They cover the requirements that CK-1 to CK-5 do not test.

    verification def 'CK-6 PROPOSED PlannerPowerAndDelayTests' {
        doc /* Proposed: unit tests that the planner uses the active preset on road cells, picks
             * the sunniest allowed heading, respects the battery reserve, applies the energy
             * penalty and finishes each plan within 5 min; that delay is sampled from 6 to 10 s;
             * that unacknowledged commands are resent after 10 s and drops are logged; and that
             * visibility uses the 2 m and 1 m heights. */
        @VerificationMethod { kind = test; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify roadSpeedAndSlip;
            verify headingForSun;
            verify hardLimits;
            verify timeAndEnergy;
            verify arrivalObjective;
            verify planTime;
            verify delaySampling;
            verify commandHandshake;
            verify visibilityHeights;
        }
    }

    verification def 'CK-7 PROPOSED ResultsAndDeliveryReview' {
        doc /* Proposed: review that results report time, energy, risk and reliability either way,
             * carry the caveat, describe R2 as selected, use Connecting Ridge with the selection
             * rules, that the run set works without the final display, and that the scenario
             * configuration exposes every assumed value. */
        @VerificationMethod { kind = inspect; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify comparison;
            verify reportEitherWay;
            verify caveat;
            verify r2Framing;
            verify siteAndPatchSelection;
            verify displayIndependence;
            verify assumedValuesConfigurable;
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

    verification def 'CK-H9 PROPOSED CaveatCheck' {
        doc /* Proposed: check that anything shown with the rover carries the scale-model caveat. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective { verify scaleModelCaveat; }
    }
}

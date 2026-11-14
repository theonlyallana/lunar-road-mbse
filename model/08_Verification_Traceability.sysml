package LRD_Verification {
    doc /*
     * Verification cases: CK-1 to CK-5 and CK-H1 to CK-H8 from the specs, and the proposed
     * CK-6 to CK-9, CK-H9 and CK-H10 (PROPOSED in their names). Each check verifies only what
     * its pass condition tests. Also: satisfy relations, and allocation of run steps to parts.
     * None of the hardware checks has been run yet, because nothing is built.
     */

    private import VerificationCases::*;
    private import VerificationMethodKind::*;
    public import LRD_Requirements_Sim::*;
    public import LRD_Requirements_Hardware::*;
    public import LRD_Behaviour::*;

    // =====================================================================
    // Designs that the requirements are placed on
    // =====================================================================

    part mvpDesign : LunarRoadDemoSystem {
        part :>> rover {
            exhibit state modes : RoverModes;
        }
    }

    part roverBuild : TabletopRover;
    part demoPresentation : DemoPresentation;

    satisfy simulationSpecification by mvpDesign;
    satisfy presentationSpecification by demoPresentation;
    satisfy hardwareSpecification by roverBuild;
    satisfy roverPresentationSpecification by demoPresentation;

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
    // Verification cases
    // =====================================================================

    verification def 'CK-1 FairAndRepeatable' {
        doc /* Pass: Both runs differ only by the road setting, and the same seed gives the same
             * result. */
        @VerificationMethod { kind = test; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify roadComparison;
            verify fixedScenario;
            verify roadOnlyChangesFlags;
            verify repeatableRuns;
        }
    }

    verification def 'CK-2 LimitsRespected' {
        doc /* Pass: No route enters a cell above 15° or drives without Earth in view. */
        @VerificationMethod { kind = (test, analyze); }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify slopeLimit;
            verify earthLimit;
            verify earthBeforeWaypoint;
        }
    }

    verification def 'CK-3 PowerModelCorrect' {
        doc /* Pass: With the Sun at 0° on a rear corner the solar input is 450 W, and a 600 W load
             * takes a full battery to empty in 9.0 h, both within 5% (TBR); with the Sun on a full
             * battery, state of charge stays at 1 and the surplus is discarded. The drain check
             * tests code only. */
        @VerificationMethod { kind = (analyze, test); }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify solarReferenceCase;
            verify drainReferenceCase;
            verify chargeBounds;
            verify excessSolarDiscarded;
        }
    }

    verification def 'CK-4 ShadowsBelievable' {
        doc /* Pass: Shadows come from terrain, the shadow calculation uses the wider terrain map,
             * and at least 80% (TBR) of shadow-edge speeds fall within the published 0.1 to 1.8
             * cm/s. */
        @VerificationMethod { kind = analyze; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify visibilityFromTerrain;
            verify widerTerrainForShadows;
            verify shadowCredibility;
        }
    }

    verification def 'CK-5 DemoWorksEndToEnd' {
        doc /* Pass: A viewer can change every control and see the route, charge, shadow and results
             * update from the stored run set. */
        @VerificationMethod { kind = demo; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify precomputedRunSet;
        }
    }

    verification def 'CK-6 PROPOSED PlannerPowerAndDelayTests' {
        doc /* Proposed check, not in the original spec. Pass: Unit tests pass for: preset values on
             * road and off-road cells; heading choice in sun and shadow; the reserve limit; time and
             * energy; route cost; plan time and full-resolution recheck; delay sampling, status
             * period, command acknowledgement and resend, no status resend, and logging; failure
             * conditions. */
        @VerificationMethod { kind = test; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify offRoadMobility;
            verify roadMobility;
            verify headingOffsetLimit;
            verify sunlitHeading;
            verify shadowHeading;
            verify timeAndEnergy;
            verify reserveLimit;
            verify routeCost;
            verify planTime;
            verify fullResolutionRecheck;
            verify delaySampling;
            verify statusPeriod;
            verify commandBeforeWaypoint;
            verify commandResend;
            verify statusReplacement;
            verify dropAndResendLogging;
            verify failureConditions;
            verify commandAcknowledgement;
        }
    }

    verification def 'CK-7 PROPOSED PresentationReview' {
        doc /* Proposed check, not in the original spec. Pass: Every shared result and presentation
             * reports results either way, carries both caveats, and describes R2 as selected. */
        @VerificationMethod { kind = inspect; }
        subject presentation : DemoPresentation;
        objective {
            verify reportEitherWay;
            verify caveatSimplifiedModel;
            verify caveatAutonomy;
            verify r2Framing;
        }
    }

    verification def 'CK-8 PROPOSED OutputsAndConfigReview' {
        doc /* Proposed check, not in the original spec. Pass: Run outputs contain every reported
             * result, the risk and reliability measures, and the road-on minus road-off differences;
             * the scenario file exposes every value marked Assumed; the site and patch follow the
             * selection rules; the run set is generated and stored without the final display
             * installed. */
        @VerificationMethod { kind = inspect; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify reportedResults;
            verify riskAndReliability;
            verify reliabilityMeasure;
            verify comparisonDifference;
            verify assumedValuesConfigurable;
            verify demoSite;
            verify patchSelectionRules;
            verify displayIndependence;
        }
    }

    verification def 'CK-9 PROPOSED InterfaceInspection' {
        doc /* Proposed check, not in the original spec. Pass: Each interface carries the listed
             * content in the listed format between the listed blocks. */
        @VerificationMethod { kind = inspect; }
        subject sim : LunarRoadDemoSystem;
        objective {
            verify terrainInterface;
            verify ephemerisInterface;
            verify environmentMapsInterface;
            verify commandInterface;
            verify statusInterface;
            verify runLogInterface;
            verify scenarioInterface;
        }
    }

    verification def 'CK-H1 MeasureFinishedRover' {
        doc /* Pass: 170 × 170 mm footprint and 50 × 20 mm wheels, within ±2 mm; all listed features
             * present. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective {
            verify footprint;
            verify wheelSize;
            verify boxBody;
            verify cornerWheels;
            verify sidePanels;
            verify frontMast;
        }
    }

    verification def 'CK-H2 PrintEveryPart' {
        doc /* Pass: Each part prints on a 180 mm bed without supports. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective {
            verify printable;
        }
    }

    verification def 'CK-H3 LevelSpeedRun' {
        doc /* Pass: Driving 1 m at a commanded 2 cm/s on level ground takes 45.5 to 55.5 s. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective {
            verify levelSpeed;
        }
    }

    verification def 'CK-H4 RampAndTurn' {
        doc /* Pass: Drives up a 15° ramp of the demo surface without stalling, then completes a 360°
             * turn on the flat demo surface. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective {
            verify slopeClimb;
            verify turnOnSpot;
        }
    }

    verification def 'CK-H5 EnduranceRun' {
        doc /* Pass: Driving continuously from freshly charged cells, still driving after 2 h. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective {
            verify endurance;
        }
    }

    verification def 'CK-H6 WaypointsAndCommsLoss' {
        doc /* Pass: Five waypoints sent over Wi-Fi are followed, and status messages with position,
             * heading and battery voltage return; after sending stops, the rover stops within 1 s
             * once 1 s has passed with no message. */
        @VerificationMethod { kind = test; }
        subject rover : TabletopRover;
        objective {
            verify wifiCommands;
            verify wifiStatus;
            verify safeStop;
        }
    }

    verification def 'CK-H7 TotalReceipts' {
        doc /* Pass: Total under £300. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective {
            verify cost;
        }
    }

    verification def 'CK-H8 WeighRover' {
        doc /* Pass: Under 0.8 kg. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective {
            verify massLimit;
        }
    }

    verification def 'CK-H9 PROPOSED CaveatCheck' {
        doc /* Proposed check, not in the original spec. Pass: Everything shown with the rover
             * carries both caveats. */
        @VerificationMethod { kind = inspect; }
        subject presentation : DemoPresentation;
        objective {
            verify scaleModelCaveat;
            verify noPerformanceClaims;
        }
    }

    verification def 'CK-H10 PROPOSED ChargingCheck' {
        doc /* Proposed check, not in the original spec. Pass: Inspection shows no charge path to the
             * fitted cells. */
        @VerificationMethod { kind = inspect; }
        subject rover : TabletopRover;
        objective {
            verify chargingSafety;
        }
    }

}

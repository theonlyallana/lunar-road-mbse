package LRD_Requirements_Sim {
    doc /*
     * Simulation requirements, taken word for word in meaning from the MVP spec.
     * REQ-M, REQ-P, REQ-E, REQ-C and REQ-R IDs match the spec. The spec gives no IDs
     * to its other "shall" statements, so REQ-MVP1 to REQ-MVP10 are assigned here.
     * Where a requirement has a number, it is also written as a checkable constraint.
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    public import LRD_Structure::*;

    requirement def SimRequirement {
        doc /* Every simulation requirement is placed on the whole demo system. */
        subject sim : LunarRoadDemoSystem;
    }

    // ---------------------------------------------------------------------
    // Purpose and reporting
    // ---------------------------------------------------------------------

    requirement <'REQ-MVP1'> comparison : SimRequirement {
        doc /* The MVP shall compare the same VIPER-class rover trip with and without a road,
             * on real lunar south polar terrain, and report the difference in time, energy,
             * risk and reliability. */
    }

    requirement <'REQ-MVP2'> reportEitherWay : SimRequirement {
        doc /* Results shall be reported whichever way they turn out, including if the road
             * makes little difference. */
    }

    requirement <'REQ-MVP3'> caveat : SimRequirement {
        doc /* Every shared result shall state that it comes from a simplified model using
             * assumed rover loads, slip and road performance. VIPER is driven by a human team,
             * while this demo plans automatically. */
    }

    // ---------------------------------------------------------------------
    // Model 1: Mobility
    // ---------------------------------------------------------------------

    requirement <'REQ-M1'> roadSpeedAndSlip : SimRequirement {
        doc /* Speed made good and slip shall use the no-road values off-road, and the active
             * preset on road cells. */
    }

    requirement <'REQ-M2'> slopeLimit : SimRequirement {
        doc /* The planner shall reject cells above the 15 degree slope limit. */
        require constraint { sim.planner.maxPlannedSlope <= 15 ['°'] }
    }

    requirement <'REQ-M3'> headingForSun : SimRequirement {
        doc /* Body heading may differ from travel direction by up to plus or minus 50 degrees
             * (assumed) while driving.
             * In sunlight the rover shall choose the allowed heading with the most solar input;
             * in shadow it shall face its direction of travel. */
        require constraint { sim.rover.mobility.maxHeadingOffset <= 50 ['°'] }
    }

    // ---------------------------------------------------------------------
    // Model 2: Power
    // ---------------------------------------------------------------------

    requirement <'REQ-P1'> loadModel : SimRequirement {
        doc /* Load shall be the awake load, plus driving power multiplied by the moving fraction. */
    }

    requirement <'REQ-P2'> chargeBounds : SimRequirement {
        doc /* Charge shall stay between 0% and 100%, with excess solar power discarded. */
        require constraint {
            sim.rover.power.stateOfCharge >= 0.0 and sim.rover.power.stateOfCharge <= 1.0
        }
    }

    // ---------------------------------------------------------------------
    // Model 3: Environment and road maps
    // ---------------------------------------------------------------------

    requirement <'REQ-E1'> visibilityFromTerrain : SimRequirement {
        doc /* Sun and Earth visibility shall be calculated from terrain, not hand-painted. */
    }

    requirement <'REQ-E2'> visibilityHeights : SimRequirement {
        doc /* Earth visibility shall use 2 m height and sunlight 1 m height (both assumed). */
        require constraint {
            sim.environment.earthVisibilityHeight == 2 [m] and
            sim.environment.sunlightHeight == 1 [m]
        }
    }

    requirement <'REQ-E3'> roadOnlyChangesFlags : SimRequirement {
        doc /* Turning the road off shall change only the road flags. */
    }

    // ---------------------------------------------------------------------
    // Model 4: Command delay
    // ---------------------------------------------------------------------

    requirement <'REQ-C1'> delaySampling : SimRequirement {
        doc /* Round-trip delay shall be sampled from 6 to 10 s. Rover state and status messages
             * shall update every 60 s (assumed), with message delays handled as timed events. */
        require constraint {
            sim.commLink.minRoundTrip == 6 [s] and
            sim.commLink.maxRoundTrip == 10 [s]
        }
    }

    requirement <'REQ-C2'> commandHandshake : SimRequirement {
        doc /* The rover shall not start a new waypoint without a command, or while Earth is out
             * of view. A command with no acknowledgement within 10 s shall be resent, and a dropped
             * status message is replaced by the next one. Drops and resends shall be logged. */
        require constraint { sim.commLink.ackTimeout == 10 [s] }
    }

    // ---------------------------------------------------------------------
    // Model 5: Planner
    // ---------------------------------------------------------------------

    requirement <'REQ-R1'> timeAndEnergy : SimRequirement {
        doc /* The planner shall work out time and energy from the active speed, slip and load. */
    }

    requirement <'REQ-R2'> hardLimits : SimRequirement {
        doc /* Hard limits shall be slope, battery reserve, and no driving without Earth in view. */
    }

    requirement <'REQ-R3'> arrivalObjective : SimRequirement {
        doc /* The planner shall minimise arrival time, with an energy penalty of 0.001 h per Wh
             * drawn from the battery (assumed and configurable). */
    }

    requirement <'REQ-R4'> planTime : SimRequirement {
        doc /* The planner may use a coarser grid, but each plan shall finish within 5 min (assumed)
             * and the final route shall be rechecked at full resolution. */
        require constraint { sim.planner.maxPlanTime <= 5 [min] }
    }

    // ---------------------------------------------------------------------
    // Scenario, data and delivery (spec "shall" statements without IDs)
    // ---------------------------------------------------------------------

    requirement <'REQ-MVP4'> assumedValuesConfigurable : SimRequirement {
        doc /* Every assumed value shall be configurable. */
    }

    requirement <'REQ-MVP5'> fixedScenario : SimRequirement {
        doc /* Each comparison shall use one fixed start, goal, start time and terrain map. */
    }

    requirement <'REQ-MVP6'> widerTerrainForShadows : SimRequirement {
        doc /* The shadow calculation shall use a wider, lower-resolution terrain map around
             * the 2 km patch, because distant ridges cast shadows into the area. */
    }

    requirement <'REQ-MVP7'> siteAndPatchSelection : SimRequirement {
        doc /* The demo shall use Connecting Ridge. The 2 km patch and scenario date shall be
             * chosen from the data using the spec's selection rules, in order. */
    }

    requirement <'REQ-MVP8'> r2Framing : SimRequirement {
        doc /* Scenario R2 shall be described as selected to illustrate the problem, not as a
             * typical trip. */
    }

    requirement <'REQ-MVP9'> precomputedRunSet : SimRequirement {
        doc /* Every control combination shall be precomputed and stored, so the viewer changes
             * results without replanning: 3 no-road and 9 road runs per scenario, 24 in total. */
        require constraint { sim.display.storedRuns == 24 }
    }

    requirement <'REQ-MVP10'> displayIndependence : SimRequirement {
        doc /* The simulation core and stored run set shall stay independent of the final display. */
    }

    // Not modelled: the spec's handover duty that the simulation engineer shall propose
    // tools, schedule, budget and code ownership. It is a project duty, not a system requirement.

    // ---------------------------------------------------------------------
    // Specification group, used for the satisfy relation
    // ---------------------------------------------------------------------

    requirement simulationSpecification : SimRequirement {
        doc /* All MVP simulation requirements. */
        require comparison;
        require reportEitherWay;
        require caveat;
        require roadSpeedAndSlip;
        require slopeLimit;
        require headingForSun;
        require loadModel;
        require chargeBounds;
        require visibilityFromTerrain;
        require visibilityHeights;
        require roadOnlyChangesFlags;
        require delaySampling;
        require commandHandshake;
        require timeAndEnergy;
        require hardLimits;
        require arrivalObjective;
        require planTime;
        require assumedValuesConfigurable;
        require fixedScenario;
        require widerTerrainForShadows;
        require siteAndPatchSelection;
        require r2Framing;
        require precomputedRunSet;
        require displayIndependence;
    }
}

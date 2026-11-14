package LRD_Requirements_Sim {
    doc /*
     * Simulation and presentation requirements, rewritten to INCOSE rules (one 'shall' each,
     * verifiable, with rationale and source). REQ-M, P, E, C and R keep the spec's IDs; a
     * decimal suffix (REQ-C2.3) marks one part of a spec requirement that was split. REQ-MVP
     * and REQ-IF IDs were assigned in this model. Modelling assumptions (ASM-*) are recorded
     * as assume constraints, not requirements. StatusInfo tbr marks a proposed value to review.
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import ModelingMetadata::*;
    private import LRD_Metadata::*;
    public import LRD_Structure::*;

    requirement def SimRequirement {
        doc /* Placed on the whole demo system. */
        subject sim : LunarRoadDemoSystem;
    }

    requirement def PresentationRequirement {
        doc /* Placed on how results and the rover are presented, not on the simulation. */
        subject presentation : DemoPresentation;
    }


    // ---------------------------------------------------------------------
    // Demo-level requirements
    // ---------------------------------------------------------------------

    requirement <'REQ-MVP1.1'> roadComparison : SimRequirement {
        doc /* The system shall run the same VIPER-class rover trip on real lunar south polar terrain
             * twice, once with the road off and once with the road on. */
        @Rationale { text = "This comparison is the purpose of the demo."; }
        @SpecSource { reference = "MVP spec, Purpose"; basis = "Split from the Purpose statement"; }
    }

    requirement <'REQ-MVP1.2'> reportedResults : SimRequirement {
        doc /* For each run, the system shall report arrival time, distance, energy used, minimum
             * state of charge, time in shadow, waiting time, peak slip, and pass or fail. */
        @Rationale { text = "These are the outputs a viewer compares between the two runs."; }
        @SpecSource { reference = "MVP spec, Purpose; Demo scenarios (reported results)"; basis = "Split from the Purpose statement"; }
    }

    requirement <'REQ-MVP1.3'> riskAndReliability : SimRequirement {
        doc /* The system shall report risk for each run as the minimum state-of-charge margin above
             * reserve, the peak slip and the time in shadow. */
        @Rationale { text = "The Purpose statement names risk but does not say how it is measured; this defines it from outputs the spec already lists."; }
        @SpecSource { reference = "MVP spec, Purpose"; basis = "New definition"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-MVP1.4'> reliabilityMeasure : SimRequirement {
        doc /* The system shall report reliability for each run as the number of dropped messages and
             * the number of resent commands. */
        @Rationale { text = "The Purpose statement names reliability but does not say how it is measured. Both counts are zero in the stored run set, which uses 0% packet drops."; }
        @SpecSource { reference = "MVP spec, Purpose"; basis = "New definition"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-MVP1.5'> comparisonDifference : SimRequirement {
        doc /* For each comparison, the system shall report the road-on minus road-off difference of
             * every reported result. */
        @Rationale { text = "The Purpose is to show the difference the road makes, not only each run's values."; }
        @SpecSource { reference = "MVP spec, Purpose"; basis = "Split from the Purpose statement"; }
    }

    requirement <'REQ-MVP2'> reportEitherWay : PresentationRequirement {
        doc /* Every presentation of the results shall report them whichever way they turn out,
             * including when the road makes little difference. */
        @Rationale { text = "A demo that only shows favourable results would mislead."; }
        @SpecSource { reference = "MVP spec, Demo scenarios"; basis = "Reworded from the Demo scenarios statement"; }
    }

    requirement <'REQ-MVP3.1'> caveatSimplifiedModel : PresentationRequirement {
        doc /* Every shared result shall state that it comes from a simplified model using assumed
             * rover loads, slip and road performance. */
        @Rationale { text = "Viewers must not read the results as predictions of real road performance."; }
        @SpecSource { reference = "MVP spec, Required caveat"; basis = "Split from the required caveat"; }
    }

    requirement <'REQ-MVP3.2'> caveatAutonomy : PresentationRequirement {
        doc /* Every shared result shall state that VIPER is driven by a human team, while this demo
             * plans automatically. */
        @Rationale { text = "The automatic planner is a simplification of how VIPER is really operated."; }
        @SpecSource { reference = "MVP spec, Required caveat"; basis = "Split from the required caveat"; }
    }

    requirement <'REQ-MVP4'> assumedValuesConfigurable : SimRequirement {
        doc /* The system shall expose every value marked Assumed in this spec as a setting in the
             * scenario file (IF-07). */
        @Rationale { text = "Assumed values are placeholders that must change as test data arrives."; }
        @SpecSource { reference = "MVP spec, Parameters"; basis = "Reworded from 'every assumed value shall be configurable'"; }
    }

    requirement <'REQ-MVP5'> fixedScenario : SimRequirement {
        doc /* Both runs of a comparison shall use the same start, goal, start time and terrain map. */
        @Rationale { text = "The road must be the only difference between the runs."; }
        @SpecSource { reference = "MVP spec, Environment conditions"; basis = "Reworded from 'each comparison shall use one fixed start, goal, start time and terrain map'"; }
    }

    requirement <'REQ-MVP6'> widerTerrainForShadows : SimRequirement {
        doc /* The shadow calculation shall include a lower-resolution terrain map extending beyond
             * the 2 km patch, with its extent to be decided. */
        @Rationale { text = "Distant ridges cast shadows into the patch. The wider map is still an open decision."; }
        @SpecSource { reference = "MVP spec, Environment conditions (source E)"; basis = "Reworded from the Environment conditions statement"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-MVP7.1'> demoSite : SimRequirement {
        doc /* The demo shall use the Connecting Ridge site, or Connecting Ridge Extension if no
             * patch at Connecting Ridge passes the selection rules. */
        @Rationale { text = "It combines strong published illumination with an image-enhanced terrain model."; }
        @SpecSource { reference = "MVP spec, Demo site selection"; basis = "Split from the site selection statements; fallback added from the spec's prose"; }
    }

    requirement <'REQ-MVP7.2'> patchSelectionRules : SimRequirement {
        doc /* The 2 km patch and scenario date shall be chosen by applying the spec's site selection
             * rules in order. */
        @Rationale { text = "Fixed rules make the choice of patch traceable rather than cherry-picked. This is a requirement on how the scenario is set up."; }
        @SpecSource { reference = "MVP spec, Demo site selection"; basis = "Split from the site selection statements"; }
    }

    requirement <'REQ-MVP8'> r2Framing : PresentationRequirement {
        doc /* Every presentation of scenario R2 shall describe it as selected to illustrate the
             * problem, not as a typical trip. */
        @Rationale { text = "R2 is chosen because a shadow matters, so it is not representative."; }
        @SpecSource { reference = "MVP spec, Demo scenarios"; basis = "Reworded from the Demo scenarios statement"; }
    }

    requirement <'REQ-MVP9'> precomputedRunSet : SimRequirement {
        doc /* The system shall precompute and store a run for every viewer control combination: 3
             * no-road and 9 road runs per scenario, 24 in total. */
        @Rationale { text = "The viewer can then change controls without replanning, in any product form."; }
        @SpecSource { reference = "MVP spec, Demo scenarios (run set)"; basis = "Reworded from the run set statement"; }
        require constraint { sim.display.storedRuns == 24 }
    }

    requirement <'REQ-MVP10'> displayIndependence : SimRequirement {
        doc /* The system shall generate and store the run set without the final display installed. */
        @Rationale { text = "The product form is not yet decided."; }
        @SpecSource { reference = "MVP spec, Handover"; basis = "Reworded from 'shall stay independent of the final display' ('usable' made testable)"; }
    }

    requirement <'REQ-MVP11'> repeatableRuns : SimRequirement {
        doc /* Given the same scenario file and random seed, the system shall produce identical run
             * results. */
        @Rationale { text = "Repeatable runs let reviewers reproduce any result and confirm that only the road changed."; }
        @SpecSource { reference = "MVP spec, MVP checks (CK-1)"; basis = "New"; }
    }

    requirement <'REQ-MVP12'> failureConditions : SimRequirement {
        doc /* The system shall mark a run as failed when charge falls below reserve, the rover
             * enters a cell above the slope limit, or the rover has not arrived by the end of the
             * scenario. */
        @Rationale { text = "Pass or fail is a reported result, so its conditions must be defined."; }
        @SpecSource { reference = "MVP spec, Demo scenarios (failure conditions)"; basis = "New ID for a spec statement"; }
    }

    requirement <'REQ-MVP13.1'> solarReferenceCase : SimRequirement {
        doc /* With the Sun at 0° elevation facing a rear corner, the power model shall give 450 W of
             * solar input, within 5%. */
        @Rationale { text = "Sets a pass tolerance and condition for the spec's 'about 450 W'."; }
        @SpecSource { reference = "MVP spec, MVP checks (CK-3)"; basis = "New"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-MVP13.2'> drainReferenceCase : SimRequirement {
        doc /* With a constant 600 W load and no solar input, the power model shall take a full
             * battery to empty in 9.0 h, within 5%. */
        @Rationale { text = "Sets a pass tolerance and condition for the spec's 'about 9 h' (5,420 Wh at 600 W)."; }
        @SpecSource { reference = "MVP spec, MVP checks (CK-3)"; basis = "New"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-MVP14'> shadowCredibility : SimRequirement {
        doc /* At least 80% of the shadow-edge speeds sampled along both runs' routes during the
             * scenario shall fall within the published 0.1 to 1.8 cm/s. */
        @Rationale { text = "Sets a pass threshold for the spec's 'most shadow-edge speeds'."; }
        @SpecSource { reference = "MVP spec, MVP checks (CK-4)"; basis = "New"; }
        @StatusInfo { status = StatusKind::tbr; }
    }


    // ---------------------------------------------------------------------
    // Interface requirements
    // ---------------------------------------------------------------------

    requirement <'REQ-IF01'> terrainInterface : SimRequirement {
        doc /* The environment model shall receive terrain height, slope and wider horizon terrain as
             * GeoTIFF on the LOLA polar stereographic grid, in metres. */
        @Rationale { text = "Defined interfaces let each model be built and tested separately."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-01)"; basis = "New, from the IF-01 row"; }
    }

    requirement <'REQ-IF02'> ephemerisInterface : SimRequirement {
        doc /* The environment model shall receive time and Sun and Earth azimuth and elevation in
             * degrees, from SPICE kernels or a table. */
        @Rationale { text = "Defined interfaces let each model be built and tested separately. The format is a proposed default."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-02)"; basis = "New, from the IF-02 row"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-IF03'> environmentMapsInterface : SimRequirement {
        doc /* The environment model shall provide slope, lit flag, Earth flag and road flag by cell
             * and time, as gridded arrays, to the planner, command link and rover. */
        @Rationale { text = "Defined interfaces let each model be built and tested separately. The format is a proposed default."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-03)"; basis = "New, from the IF-03 row"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-IF04'> commandInterface : SimRequirement {
        doc /* The planner shall send each command, with command ID, target x and y, heading and
             * mode, as a JSON message to the rover through the command delay. */
        @Rationale { text = "Routing commands through the delay is what makes communication delay part of the comparison. The format is a proposed default."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-04)"; basis = "New, from the IF-04 row"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-IF05'> statusInterface : SimRequirement {
        doc /* The rover shall send each status, with time, x, y, heading, state of charge, mode and
             * command status, as a JSON message to the planner through the command delay. */
        @Rationale { text = "The planner only knows the rover state that reaches it through the delay. The format is a proposed default."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-05)"; basis = "New, from the IF-05 row"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-IF06'> runLogInterface : SimRequirement {
        doc /* The planner and rover shall write the route, state, solar power, load, events and
             * results to the display and log, as Parquet or CSV. */
        @Rationale { text = "The stored run set and the display both depend on this log. The format is a proposed default."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-06)"; basis = "New, from the IF-06 row"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement <'REQ-IF07'> scenarioInterface : SimRequirement {
        doc /* Every block shall read the road setting, preset, start, goal, start time, seed and
             * parameters from one versioned YAML scenario file. */
        @Rationale { text = "One versioned file keeps every block on the same settings and makes runs repeatable. The format is a proposed default."; }
        @SpecSource { reference = "MVP spec, Interfaces (IF-07)"; basis = "New, from the IF-07 row"; }
        @StatusInfo { status = StatusKind::tbr; }
    }


    // ---------------------------------------------------------------------
    // Model 1: Mobility
    // ---------------------------------------------------------------------

    requirement <'REQ-M1.1'> offRoadMobility : SimRequirement {
        doc /* On off-road cells, the mobility model shall use the no-road speed made good and slip
             * values. */
        @Rationale { text = "Off-road behaviour is the baseline the road is compared against."; }
        @SpecSource { reference = "MVP spec, Simulation models 1"; basis = "Split from REQ-M1"; }
    }

    requirement <'REQ-M1.2'> roadMobility : SimRequirement {
        doc /* On road cells, the mobility model shall use the active road preset's speed made good
             * and slip values. */
        @Rationale { text = "The road's effect enters the simulation only through the preset values."; }
        @SpecSource { reference = "MVP spec, Simulation models 1"; basis = "Split from REQ-M1"; }
    }

    requirement <'REQ-M2'> slopeLimit : SimRequirement {
        doc /* The planner shall reject cells above the 15° slope limit. */
        @Rationale { text = "VIPER's published slope limit (sources B and C)."; }
        @SpecSource { reference = "MVP spec, Simulation models 1"; basis = "Spec"; }
        require constraint { sim.planner.maxPlannedSlope <= 15 ['°'] }
    }

    requirement <'REQ-M3.1'> headingOffsetLimit : SimRequirement {
        doc /* While driving, the rover's body heading shall stay within ±50° of its direction of
             * travel. */
        @Rationale { text = "Allows the rover to turn its panels towards the Sun while driving; the 50° is assumed."; }
        @SpecSource { reference = "MVP spec, Simulation models 1"; basis = "Split from REQ-M3"; }
        require constraint { sim.rover.mobility.maxHeadingOffset <= 50 ['°'] }
    }

    requirement <'REQ-M3.2'> sunlitHeading : SimRequirement {
        doc /* In sunlight, the rover shall choose the allowed heading with the most solar input. */
        @Rationale { text = "Maximises charging while driving."; }
        @SpecSource { reference = "MVP spec, Simulation models 1"; basis = "Split from REQ-M3"; }
    }

    requirement <'REQ-M3.3'> shadowHeading : SimRequirement {
        doc /* In shadow, the rover shall face its direction of travel. */
        @Rationale { text = "There is no solar input to gain by turning."; }
        @SpecSource { reference = "MVP spec, Simulation models 1"; basis = "Split from REQ-M3"; }
    }


    // ---------------------------------------------------------------------
    // Model 2: Power
    // ---------------------------------------------------------------------

    requirement <'REQ-P2.1'> chargeBounds : SimRequirement {
        doc /* The power model shall keep state of charge between 0 and 1. */
        @Rationale { text = "Charge outside this range has no physical meaning."; }
        @SpecSource { reference = "MVP spec, Simulation models 2"; basis = "Split from REQ-P2"; }
        require constraint { sim.rover.power.stateOfCharge >= 0.0 and sim.rover.power.stateOfCharge <= 1.0 }
    }

    requirement <'REQ-P2.2'> excessSolarDiscarded : SimRequirement {
        doc /* The power model shall discard solar power that a full battery cannot accept. */
        @Rationale { text = "Stops a full battery being credited with energy it cannot store."; }
        @SpecSource { reference = "MVP spec, Simulation models 2"; basis = "Split from REQ-P2"; }
    }


    // ---------------------------------------------------------------------
    // Model 3: Environment and road maps
    // ---------------------------------------------------------------------

    requirement <'REQ-E1'> visibilityFromTerrain : SimRequirement {
        doc /* The environment model shall calculate Sun and Earth visibility for each cell from the
             * terrain horizon and the ephemeris. */
        @Rationale { text = "Real terrain shadows are what make the comparison credible."; }
        @SpecSource { reference = "MVP spec, Simulation models 3"; basis = "Reworded from 'calculated from terrain, not hand-painted'"; }
    }

    requirement <'REQ-E3'> roadOnlyChangesFlags : SimRequirement {
        doc /* Turning the road off shall change only the road flags in the environment maps. */
        @Rationale { text = "The road must be the only difference between the runs."; }
        @SpecSource { reference = "MVP spec, Simulation models 3"; basis = "Reworded from REQ-E3"; }
    }


    // ---------------------------------------------------------------------
    // Model 4: Command delay
    // ---------------------------------------------------------------------

    requirement <'REQ-C1.1'> delaySampling : SimRequirement {
        doc /* The command link shall sample each round-trip delay uniformly from 6 to 10 s. */
        @Rationale { text = "The published round-trip range (source B). A uniform distribution is assumed."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C1"; }
        @StatusInfo { status = StatusKind::tbr; }
        require constraint { sim.commLink.minRoundTrip == 6 [s] and sim.commLink.maxRoundTrip == 10 [s] }
    }

    requirement <'REQ-C1.2'> statusPeriod : SimRequirement {
        doc /* The rover shall send a status message every 60 s. */
        @Rationale { text = "Sets how quickly the planner learns the rover state; the 60 s is assumed."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C1"; }
        require constraint { sim.commLink.statusPeriod == 60 [s] }
    }

    requirement <'REQ-C2.1'> commandBeforeWaypoint : SimRequirement {
        doc /* The rover shall not start a new waypoint without a received command. */
        @Rationale { text = "The rover drives only on commands from the planner."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C2"; }
    }

    requirement <'REQ-C2.2'> earthBeforeWaypoint : SimRequirement {
        doc /* The rover shall not start a new waypoint while Earth is out of view. */
        @Rationale { text = "Commands need a direct-to-Earth link."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C2"; }
    }

    requirement <'REQ-C2.3'> commandResend : SimRequirement {
        doc /* The planner shall resend a command for which no acknowledgement has arrived within 15
             * s. */
        @Rationale { text = "A dropped command must not stall the trip. The timeout must exceed the 10 s maximum round trip, or every command would be resent; the spec's 10 s is raised to 15 s."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C2; timeout raised from 10 s"; }
        @StatusInfo { status = StatusKind::tbr; }
        require constraint { sim.commLink.ackTimeout == 15 [s] }
    }

    requirement <'REQ-C2.4'> statusReplacement : SimRequirement {
        doc /* The rover shall not resend a dropped status message. */
        @Rationale { text = "Status is periodic, so the next scheduled message supersedes a lost one."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C2"; }
    }

    requirement <'REQ-C2.5'> dropAndResendLogging : SimRequirement {
        doc /* The system shall log every dropped and resent message. */
        @Rationale { text = "Drops and resends feed the reliability result (REQ-MVP1.4)."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "Split from REQ-C2"; }
    }

    requirement <'REQ-C2.6'> commandAcknowledgement : SimRequirement {
        doc /* The rover shall send an acknowledgement through the command delay as soon as it
             * receives a command. */
        @Rationale { text = "REQ-C2.3 needs an acknowledgement; the 60 s status message is too slow to serve as one."; }
        @SpecSource { reference = "MVP spec, Simulation models 4"; basis = "New"; }
        @StatusInfo { status = StatusKind::tbr; }
    }


    // ---------------------------------------------------------------------
    // Model 5: Planner
    // ---------------------------------------------------------------------

    requirement <'REQ-R1'> timeAndEnergy : SimRequirement {
        doc /* For each route it evaluates, the planner shall calculate travel time and energy from
             * the active speed, slip and load. */
        @Rationale { text = "Time and energy are what the road changes."; }
        @SpecSource { reference = "MVP spec, Simulation models 5"; basis = "Reworded from REQ-R1"; }
    }

    requirement <'REQ-R2.1'> reserveLimit : SimRequirement {
        doc /* The planner shall not plan driving that takes state of charge below the battery
             * reserve. */
        @Rationale { text = "Falling below reserve fails the run (REQ-MVP12)."; }
        @SpecSource { reference = "MVP spec, Simulation models 5"; basis = "Split from REQ-R2; the slope limit part is REQ-M2"; }
    }

    requirement <'REQ-R2.2'> earthLimit : SimRequirement {
        doc /* The planner shall not plan driving while Earth is out of view. */
        @Rationale { text = "Driving needs a direct-to-Earth link."; }
        @SpecSource { reference = "MVP spec, Simulation models 5"; basis = "Split from REQ-R2"; }
    }

    requirement <'REQ-R3'> routeCost : SimRequirement {
        doc /* Among the routes it evaluates, the planner shall choose the one with the lowest cost,
             * where cost is arrival time plus 0.001 h per Wh drawn from the battery. */
        @Rationale { text = "A stated cost function can be checked; 'minimise' alone cannot. The energy penalty is assumed."; }
        @SpecSource { reference = "MVP spec, Simulation models 5"; basis = "Reworded from REQ-R3 ('minimise arrival time')"; }
    }

    requirement <'REQ-R4.1'> planTime : SimRequirement {
        doc /* The planner shall finish each plan within 5 min of wall-clock time. */
        @Rationale { text = "Matches the 5 min command cycle; the value is assumed."; }
        @SpecSource { reference = "MVP spec, Simulation models 5"; basis = "Split from REQ-R4"; }
        require constraint { sim.planner.maxPlanTime <= 5 [min] }
    }

    requirement <'REQ-R4.2'> fullResolutionRecheck : SimRequirement {
        doc /* The planner shall recheck the final route at full terrain resolution. */
        @Rationale { text = "A coarse-grid plan could miss a steep or shadowed cell."; }
        @SpecSource { reference = "MVP spec, Simulation models 5"; basis = "Split from REQ-R4"; }
    }


    // Not modelled: the handover duty that the simulation engineer shall propose tools,
    // schedule, budget and code ownership. It is a project duty, not a system requirement.

    // ---------------------------------------------------------------------
    // Specification groups, used for the satisfy relations
    // ---------------------------------------------------------------------

    requirement simulationSpecification : SimRequirement {
        doc /* All simulation requirements, under the modelling assumptions below. */
        assume constraint <'ASM-P1'> loadModel {
            doc /* Load is the awake load plus driving power multiplied by the moving fraction. (Was
                 * REQ-P1; it describes how the model works, not a need.) */
        }
        assume constraint <'ASM-E2'> visibilityHeights {
            doc /* Earth visibility is evaluated 2 m above the surface and sunlight 1 m above it. (Was
                 * REQ-E2; modelling choice, values assumed.) */
            sim.environment.earthVisibilityHeight == 2 [m] and sim.environment.sunlightHeight == 1 [m]
        }
        assume constraint <'ASM-C1'> timedMessageEvents {
            doc /* Message delays are handled as timed events. (Was part of REQ-C1; implementation
                 * choice.) */
        }
        require roadComparison;
        require reportedResults;
        require riskAndReliability;
        require reliabilityMeasure;
        require comparisonDifference;
        require assumedValuesConfigurable;
        require fixedScenario;
        require widerTerrainForShadows;
        require demoSite;
        require patchSelectionRules;
        require precomputedRunSet;
        require displayIndependence;
        require repeatableRuns;
        require failureConditions;
        require solarReferenceCase;
        require drainReferenceCase;
        require shadowCredibility;
        require terrainInterface;
        require ephemerisInterface;
        require environmentMapsInterface;
        require commandInterface;
        require statusInterface;
        require runLogInterface;
        require scenarioInterface;
        require offRoadMobility;
        require roadMobility;
        require slopeLimit;
        require headingOffsetLimit;
        require sunlitHeading;
        require shadowHeading;
        require chargeBounds;
        require excessSolarDiscarded;
        require visibilityFromTerrain;
        require roadOnlyChangesFlags;
        require delaySampling;
        require statusPeriod;
        require commandBeforeWaypoint;
        require earthBeforeWaypoint;
        require commandResend;
        require statusReplacement;
        require dropAndResendLogging;
        require commandAcknowledgement;
        require timeAndEnergy;
        require reserveLimit;
        require earthLimit;
        require routeCost;
        require planTime;
        require fullResolutionRecheck;
    }

    requirement presentationSpecification : PresentationRequirement {
        doc /* Requirements on how simulation results are presented. */
        require reportEitherWay;
        require caveatSimplifiedModel;
        require caveatAutonomy;
        require r2Framing;
    }
}

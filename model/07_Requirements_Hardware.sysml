package LRD_Requirements_Hardware {
    doc /*
     * Requirements for the 1:10 tabletop rover, rewritten to INCOSE rules. REQ-H1 to H10 keep
     * the spec's IDs, with decimal suffixes where a requirement was split. REQ-H11 (the spec's
     * required caveat) and REQ-H12 (charging safety, proposed) were assigned in this model.
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import ModelingMetadata::*;
    private import LRD_Metadata::*;
    public import LRD_Hardware::*;
    private import LRD_Requirements_Sim::PresentationRequirement;

    requirement def HardwareRequirement {
        subject rover : TabletopRover;
    }

    requirement <'REQ-H1.1'> footprint : HardwareRequirement {
        doc /* The rover shall fit a 170 mm × 170 mm footprint, within ±2 mm. */
        @Rationale { text = "Matches VIPER's footprint at 1:10."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H1"; }
        require constraint { rover.measuredFootprint >= 168 [mm] and rover.measuredFootprint <= 172 [mm] }
    }

    requirement <'REQ-H1.2'> wheelSize : HardwareRequirement {
        doc /* Each wheel shall be 50 mm in diameter and 20 mm wide, within ±2 mm. */
        @Rationale { text = "Matches VIPER's wheel size at 1:10."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H1"; }
        require constraint { rover.measuredWheelDiameter >= 48 [mm] and rover.measuredWheelDiameter <= 52 [mm] and rover.measuredWheelWidth >= 18 [mm] and rover.measuredWheelWidth <= 22 [mm] }
    }

    requirement <'REQ-H2.1'> boxBody : HardwareRequirement {
        doc /* The rover shall have a box-shaped body. */
        @Rationale { text = "One of VIPER's defining visual features."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H2 ('recognisable features' replaced by the list)"; }
    }

    requirement <'REQ-H2.2'> cornerWheels : HardwareRequirement {
        doc /* The rover shall have a wheel at each corner. */
        @Rationale { text = "One of VIPER's defining visual features."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H2"; }
    }

    requirement <'REQ-H2.3'> sidePanels : HardwareRequirement {
        doc /* The rover shall have panels on its rear, left and right sides. */
        @Rationale { text = "Shows where VIPER's solar arrays sit."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H2"; }
    }

    requirement <'REQ-H2.4'> frontMast : HardwareRequirement {
        doc /* The rover shall have a mast at the front. */
        @Rationale { text = "One of VIPER's defining visual features."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H2"; }
    }

    requirement <'REQ-H3'> printable : HardwareRequirement {
        doc /* All structural parts shall print in PLA on a 180 mm × 180 mm bed without supports. */
        @Rationale { text = "Keeps the build possible on a small, common printer."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Reworded from REQ-H3 (escape clause removed; the CAD section names no exception)"; }
    }

    requirement <'REQ-H4'> levelSpeed : HardwareRequirement {
        doc /* The rover shall hold a commanded speed of 2 cm/s on level ground, within ±10%. */
        @Rationale { text = "VIPER's 20 cm/s top speed at 1:10."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Spec"; }
        require constraint { rover.measuredLevelSpeed >= 1.8 [cm/s] and rover.measuredLevelSpeed <= 2.2 [cm/s] }
    }

    requirement <'REQ-H5.1'> slopeClimb : HardwareRequirement {
        doc /* The rover shall climb a 15° slope of the demo surface (the printed terrain map on a
             * rigid board, decision D2). */
        @Rationale { text = "Matches the simulation's 15° slope limit."; }
        @SpecSource { reference = "Hardware spec, Requirements; decision D2"; basis = "Split from REQ-H5; 'chosen demo surface' named from D2"; }
        require constraint { rover.maxClimbableSlope >= 15 ['°'] }
    }

    requirement <'REQ-H5.2'> turnOnSpot : HardwareRequirement {
        doc /* The rover shall turn 360° on the spot on the demo surface. */
        @Rationale { text = "Skid steering must work on the board to follow replayed routes."; }
        @SpecSource { reference = "Hardware spec, Requirements; decision D2"; basis = "Split from REQ-H5"; }
    }

    requirement <'REQ-H6'> endurance : HardwareRequirement {
        doc /* Starting from freshly charged cells, the rover shall drive continuously for at least 2
             * hours. */
        @Rationale { text = "Covers a full demo session without changing cells."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Reworded from REQ-H6 (start condition added from CK-H5)"; }
        require constraint { rover.continuousRunTime >= 2 [h] }
    }

    requirement <'REQ-H7.1'> wifiCommands : HardwareRequirement {
        doc /* The rover shall accept waypoint commands over Wi-Fi. */
        @Rationale { text = "Lets the laptop replay a stored route."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H7"; }
    }

    requirement <'REQ-H7.2'> wifiStatus : HardwareRequirement {
        doc /* The rover shall report its position, heading and battery voltage over Wi-Fi. */
        @Rationale { text = "The route player needs feedback to keep the rover on the route."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Split from REQ-H7"; }
    }

    requirement <'REQ-H8'> safeStop : HardwareRequirement {
        doc /* The rover shall stop within 1 s after 1 s passes with no message received. */
        @Rationale { text = "Stops a runaway rover if the link drops. The route player must therefore send a message at least once a second while a route runs."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Reworded from REQ-H8 (timeout made explicit, matching the safe-stop design)"; }
        require constraint { rover.commsLossStopTime <= 1 [s] }
    }

    requirement <'REQ-H9'> cost : HardwareRequirement {
        doc /* Total parts cost shall stay under £300, including filament and delivery. */
        @Rationale { text = "Project budget."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Spec"; }
        require constraint { rover.partsCostGBP < 300.0 }
    }

    requirement <'REQ-H10'> massLimit : HardwareRequirement {
        doc /* The rover's mass shall stay under 0.8 kg. */
        @Rationale { text = "The spec's motor torque margins assume this mass."; }
        @SpecSource { reference = "Hardware spec, Requirements"; basis = "Reworded from REQ-H10 (reason moved to rationale)"; }
        require constraint { rover.mass < 0.8 [kg] }
    }

    requirement <'REQ-H11.1'> scaleModelCaveat : PresentationRequirement {
        doc /* Every display, sign or video shown with the rover shall state that it is a scale model
             * driving a replayed route. */
        @Rationale { text = "Viewers must not mistake the prop for a working rover."; }
        @SpecSource { reference = "Hardware spec, Required caveat"; basis = "Split from the required caveat"; }
    }

    requirement <'REQ-H11.2'> noPerformanceClaims : PresentationRequirement {
        doc /* Every display, sign or video shown with the rover shall state that its speed, slip and
             * energy use say nothing about VIPER or a lunar road. */
        @Rationale { text = "The tabletop rover's physics do not scale to the Moon."; }
        @SpecSource { reference = "Hardware spec, Required caveat"; basis = "Split from the required caveat"; }
    }

    requirement <'REQ-H12'> chargingSafety : HardwareRequirement {
        doc /* The rover shall provide no path for charging the cells while they are fitted. */
        @Rationale { text = "The rover has no charge control, so charging NiMH cells inside it would be a heat risk. Cells are charged in an external NiMH charger."; }
        @SpecSource { reference = "Hardware spec, Parts list (charger)"; basis = "New"; }
        @StatusInfo { status = StatusKind::tbr; }
    }

    requirement hardwareSpecification : HardwareRequirement {
        doc /* All 1:10 rover build requirements. */
        require footprint;
        require wheelSize;
        require boxBody;
        require cornerWheels;
        require sidePanels;
        require frontMast;
        require printable;
        require levelSpeed;
        require slopeClimb;
        require turnOnSpot;
        require endurance;
        require wifiCommands;
        require wifiStatus;
        require safeStop;
        require cost;
        require massLimit;
        require chargingSafety;
    }

    requirement roverPresentationSpecification : PresentationRequirement {
        doc /* Requirements on how the rover is presented. */
        require scaleModelCaveat;
        require noPerformanceClaims;
    }
}

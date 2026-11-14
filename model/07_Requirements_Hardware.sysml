package LRD_Requirements_Hardware {
    doc /*
     * The ten requirements that define a finished 1:10 rover build (REQ-H1 to REQ-H10).
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    public import LRD_Hardware::*;

    requirement def HardwareRequirement {
        subject rover : TabletopRover;
    }

    requirement <'REQ-H1'> footprintAndWheels : HardwareRequirement {
        doc /* The rover shall fit a 170 mm x 170 mm footprint with 50 mm x 20 mm wheels, within 2 mm. */
        require constraint {
            rover.footprint >= 168 [mm] and rover.footprint <= 172 [mm]
        }
    }

    requirement <'REQ-H2'> viperFeatures : HardwareRequirement {
        doc /* The rover shall carry VIPER's recognisable features: a box body, a wheel at each corner,
             * panels on the rear, left and right, and a front mast. */
    }

    requirement <'REQ-H3'> printable : HardwareRequirement {
        doc /* All structural parts shall print in PLA on a 180 mm x 180 mm bed without supports. */
    }

    requirement <'REQ-H4'> levelSpeed : HardwareRequirement {
        doc /* The rover shall hold a commanded speed of 2 cm/s on level ground, within 10%. */
        require constraint {
            rover.measuredLevelSpeed >= 1.8 [cm/s] and rover.measuredLevelSpeed <= 2.2 [cm/s]
        }
    }

    requirement <'REQ-H5'> slopeAndTurn : HardwareRequirement {
        doc /* The rover shall climb a 15 degree slope and turn on the spot on the chosen demo surface. */
        require constraint { rover.maxClimbableSlope >= 15 ['°'] }
    }

    requirement <'REQ-H6'> endurance : HardwareRequirement {
        doc /* The rover shall run for at least 2 hours of continuous driving on one set of cells. */
        require constraint { rover.continuousRunTime >= 2 [h] }
    }

    requirement <'REQ-H7'> wifiCommanding : HardwareRequirement {
        doc /* The rover shall accept waypoint commands over Wi-Fi and report position, heading and
             * battery voltage. */
    }

    requirement <'REQ-H8'> safeStop : HardwareRequirement {
        doc /* The rover shall stop within 1 s if commands stop arriving. */
        require constraint { rover.commsLossStopTime <= 1 [s] }
    }

    requirement <'REQ-H9'> cost : HardwareRequirement {
        doc /* Total parts cost shall stay under GBP 300, including filament and delivery. */
        require constraint { rover.partsCostGBP < 300.0 }
    }

    requirement <'REQ-H10'> massLimit : HardwareRequirement {
        doc /* Mass shall stay under 0.8 kg, so the torque margins in the spec hold. */
        require constraint { rover.mass < 0.8 [kg] }
    }

    requirement hardwareSpecification : HardwareRequirement {
        doc /* All 1:10 rover build requirements. */
        require footprintAndWheels;
        require viperFeatures;
        require printable;
        require levelSpeed;
        require slopeAndTurn;
        require endurance;
        require wifiCommanding;
        require safeStop;
        require cost;
        require massLimit;
    }
}

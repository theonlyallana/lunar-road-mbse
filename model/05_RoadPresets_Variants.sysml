package LRD_Variants {
    doc /*
     * Variability: the road presets and awake-load presets the viewer can choose.
     * All road values are assumed placeholders until test data or a source exists.
     * Trip times assume a straight 1.5 km route with no detours or waiting.
     * The stored run set is 3 no-road plus 9 road runs per scenario, 24 in total.
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    public import LRD_Structure::*;

    part def RoadPreset {
        attribute speedMadeGoodFlat : SpeedValue;
        attribute slipMultiplier : Real;
        attribute rollingResistance : Real;
        attribute maxWaypointSpacing : LengthValue;
        attribute tripTimeStraight1500m : DurationValue;
    }

    part noRoad : RoadPreset {
        attribute :>> speedMadeGoodFlat = 0.8 [cm/s];
        attribute :>> slipMultiplier = 1.0;
        attribute :>> rollingResistance = 0.2;
        attribute :>> maxWaypointSpacing = 8 [m];
        attribute :>> tripTimeStraight1500m = 52 [h];
    }

    part halfBenefit : RoadPreset {
        attribute :>> speedMadeGoodFlat = 1.2 [cm/s];
        attribute :>> slipMultiplier = 0.75;
        attribute :>> rollingResistance = 0.15;
        attribute :>> maxWaypointSpacing = 8 [m];
        attribute :>> tripTimeStraight1500m = 35 [h];
    }

    part expectedBenefit : RoadPreset {
        attribute :>> speedMadeGoodFlat = 1.6 [cm/s];
        attribute :>> slipMultiplier = 0.5;
        attribute :>> rollingResistance = 0.1;
        attribute :>> maxWaypointSpacing = 8 [m];
        attribute :>> tripTimeStraight1500m = 26 [h];
    }

    part highBenefit : RoadPreset {
        attribute :>> speedMadeGoodFlat = 3.2 [cm/s];
        attribute :>> slipMultiplier = 0.25;
        attribute :>> rollingResistance = 0.05;
        attribute :>> maxWaypointSpacing = 16 [m];
        attribute :>> tripTimeStraight1500m = 13 [h];
    }

    variation part def RoadPresetChoices :> RoadPreset {
        variant noRoad;
        variant halfBenefit;
        variant expectedBenefit;
        variant highBenefit;
    }

    variation attribute def AwakeLoadChoices :> PowerValue {
        variant attribute lowLoad = 150 [W];
        variant attribute nominalLoad = 250 [W];
        variant attribute highLoad = 350 [W];
    }

    enum def ScenarioKind {
        doc /* R1 baseline with no moving shadow on the main route; R2 with a real moving shadow. */
        R1_Baseline;
        R2_MovingShadow;
    }

    // The family of runs the viewer can select from
    abstract part demoRunFamily : LunarRoadDemoSystem {
        part roadPreset : RoadPresetChoices[1];
        attribute awakeLoadPreset : AwakeLoadChoices[1];
        attribute scenarioKind : ScenarioKind;
    }

    // Two example configurations from the run set
    part r1NoRoadNominal :> demoRunFamily {
        part redefines roadPreset = roadPreset::noRoad;
        attribute redefines awakeLoadPreset = awakeLoadPreset::nominalLoad;
        attribute redefines scenarioKind = ScenarioKind::R1_Baseline;
    }

    part r2ExpectedRoadNominal :> demoRunFamily {
        part redefines roadPreset = roadPreset::expectedBenefit;
        attribute redefines awakeLoadPreset = awakeLoadPreset::nominalLoad;
        attribute redefines scenarioKind = ScenarioKind::R2_MovingShadow;
    }
}

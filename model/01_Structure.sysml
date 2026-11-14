package LRD_Structure {
    doc /*
     * Lunar Road Demo MVP: logical architecture of the simulation system.
     * Source: "Lunar Road Demo MVP: System Boundary and Simulation Conditions".
     * Sourced values are bound with '='. Assumed values use 'default' so they
     * stay configurable, as the spec requires.
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;

    // =====================================================================
    // External context: things the system uses but cannot change
    // =====================================================================

    part def LunarTerrain {
        doc /* NASA enhanced 5 m/pixel model for Connecting Ridge, LOLA Site01 as fallback. */
        port terrainOut : TerrainPort;
    }

    part def SunAndEarthEphemeris {
        doc /* SPICE kernels or a table giving Sun and Earth azimuth and elevation. */
        port ephemerisOut : EphemerisPort;
    }

    part def DemoViewer {
        doc /* Person running the comparison and changing the road assumptions. */
    }

    // =====================================================================
    // Items carried on the interfaces (IF-01 to IF-07)
    // =====================================================================

    item def TerrainData {
        doc /* IF-01: height (m), slope and wider horizon terrain. GeoTIFF on the LOLA polar stereographic grid.
             * The 5 m cell size applies to the 2 km patch; the wider horizon terrain is lower resolution. */
        attribute patchCellSize : LengthValue = 5 [m];
    }

    item def EphemerisData {
        doc /* IF-02: time, Sun and Earth azimuth and elevation (degrees). */
        attribute time : DurationValue;
        attribute sunAzimuth : AngularMeasureValue;
        attribute sunElevation : AngularMeasureValue;
        attribute earthAzimuth : AngularMeasureValue;
        attribute earthElevation : AngularMeasureValue;
    }

    item def EnvironmentMaps {
        doc /* IF-03: slope, lit flag, Earth flag and road flag by cell and time. Gridded arrays. */
        attribute slope : AngularMeasureValue;
        attribute isLit : Boolean;
        attribute earthInView : Boolean;
        attribute isRoad : Boolean;
    }

    item def Command {
        doc /* IF-04: planner to rover, through the delay. JSON message. */
        attribute commandId : String;
        attribute targetX : LengthValue;
        attribute targetY : LengthValue;
        attribute heading : AngularMeasureValue;
        attribute mode : String;
    }

    item def RoverStatus {
        doc /* IF-05: rover to planner, through the delay. JSON message. */
        attribute time : DurationValue;
        attribute x : LengthValue;
        attribute y : LengthValue;
        attribute heading : AngularMeasureValue;
        attribute stateOfCharge : Real;
        attribute mode : String;
        attribute commandStatus : String;
    }

    item def RunRecord {
        doc /* IF-06: time-stamped route, state, solar power, load, events and results. Parquet or CSV. */
        attribute time : DurationValue;
        attribute x : LengthValue;
        attribute y : LengthValue;
        attribute stateOfCharge : Real;
        attribute solarPower : PowerValue;
        attribute load : PowerValue;
        attribute eventText : String;
    }

    item def ScenarioSettings {
        doc /* IF-07: road on or off, preset, start, goal, start time, seed and parameters. Versioned YAML. */
        attribute roadOn : Boolean;
        attribute preset : String;
        attribute startX : LengthValue;
        attribute startY : LengthValue;
        attribute goalX : LengthValue;
        attribute goalY : LengthValue;
        attribute startTime : String;
        attribute seed : Integer;
    }

    // =====================================================================
    // Ports
    // =====================================================================

    port def TerrainPort      { out item terrain : TerrainData; }
    port def EphemerisPort    { out item ephemeris : EphemerisData; }
    port def EnvMapsPort      { out item maps : EnvironmentMaps; }
    port def CommandPort      { out item command : Command; }
    port def StatusPort       { out item status : RoverStatus; }
    port def RunRecordPort    { out item record : RunRecord; }
    port def ScenarioPort     { out item settings : ScenarioSettings; }

    // =====================================================================
    // Interface definitions, one per IF in the spec
    // =====================================================================

    interface def 'IF-01 TerrainInterface'   { end source : TerrainPort;   end sink : ~TerrainPort; }
    interface def 'IF-02 EphemerisInterface' { end source : EphemerisPort; end sink : ~EphemerisPort; }
    interface def 'IF-03 EnvMapsInterface'   { end source : EnvMapsPort;   end sink : ~EnvMapsPort; }
    interface def 'IF-04 CommandInterface'   { end source : CommandPort;   end sink : ~CommandPort; }
    interface def 'IF-05 StatusInterface'    { end source : StatusPort;    end sink : ~StatusPort; }
    interface def 'IF-06 RunRecordInterface' { end source : RunRecordPort; end sink : ~RunRecordPort; }
    interface def 'IF-07 ScenarioInterface'  { end source : ScenarioPort;  end sink : ~ScenarioPort; }

    // =====================================================================
    // Logical elements (the five simulation models plus display and config)
    // =====================================================================

    part def EnvironmentModel {
        doc /* Model 3: Sun and Earth visibility from terrain horizons; road cells from a fixed centreline. */
        attribute mapArea : LengthValue default 2000 [m];
        attribute roadWidth : LengthValue default 10 [m];
        attribute environmentStep : DurationValue default 15 [min];
        attribute earthVisibilityHeight : LengthValue default 2 [m];
        attribute sunlightHeight : LengthValue default 1 [m];
        port terrainIn : ~TerrainPort;
        port ephemerisIn : ~EphemerisPort;
        port mapsOut : EnvMapsPort;
        port settingsIn : ~ScenarioPort;
    }

    part def MobilityModel {
        doc /* Model 1: speed made good on flat ground, reduced by slip on slopes. */
        attribute nominalSpeed : SpeedValue = 10 [cm/s];
        attribute topSpeed : SpeedValue = 20 [cm/s];
        attribute offRoadSpeedMadeGood : SpeedValue = 0.8 [cm/s];
        attribute slopeLimit : AngularMeasureValue = 15 ['°'];
        attribute maxHeadingOffset : AngularMeasureValue default 50 ['°'];
        attribute offRoadRollingResistance : Real default 0.2;
        attribute movingFraction : Real;   // constant for each preset (REQ-P1)
        attribute currentSlope : AngularMeasureValue;
        attribute slip : Real;            // off-road: 2% at 0, 5% at 5, 10% at 10, 20% at 15 degrees (assumed)
    }

    part def PowerModel {
        doc /* Model 2: battery state updated each step as solar input minus load. */
        attribute batteryCapacity : EnergyValue = 5420 [W*h];   // at start of life, 0 C
        attribute solarPerPanel : PowerValue = 320 [W];
        attribute solarAtCorner : PowerValue = 450 [W];
        attribute batteryReserveFraction : Real default 0.2;
        attribute awakeLoad : PowerValue default 250 [W];
        attribute drivetrainEfficiency : Real default 0.5;
        attribute stateOfCharge : Real;
    }

    part def RoverModel {
        doc /* One VIPER-class rover. Mass and footprint from NASA 2024 slides (source A). */
        attribute rovingMass : MassValue = 447 [kg];
        attribute footprint : LengthValue = 1.7 [m];
        part mobility : MobilityModel;
        part power : PowerModel;
        port mapsIn : ~EnvMapsPort;
        port commandIn : ~CommandPort;
        port statusOut : StatusPort;
        port recordOut : RunRecordPort;
        port settingsIn : ~ScenarioPort;
    }

    part def CommandDelayLink {
        doc /* Model 4: each message waits half of a sampled 6 to 10 s round trip; optional drops. */
        attribute minRoundTrip : DurationValue = 6 [s];
        attribute maxRoundTrip : DurationValue = 10 [s];
        attribute statusPeriod : DurationValue default 60 [s];
        attribute ackTimeout : DurationValue default 10 [s];
        attribute packetDropRate : Real default 0.0;
        port mapsIn : ~EnvMapsPort;
        port commandIn : ~CommandPort;
        port commandOut : CommandPort;
        port statusIn : ~StatusPort;
        port statusOut : StatusPort;
        port settingsIn : ~ScenarioPort;
    }

    part def Planner {
        doc /* Model 5: the same time-aware planner runs in both cases, so any difference comes from the road. */
        attribute commandCycle : DurationValue = 5 [min];
        attribute minWaypointSpacing : LengthValue = 4 [m];   // off-road, sourced
        attribute maxWaypointSpacing : LengthValue = 8 [m];   // off-road, sourced; road limit set by preset
        attribute energyPenalty : Real default 0.001;   // hours per Wh drawn
        attribute maxPlanTime : DurationValue default 5 [min];
        attribute maxPlannedSlope : AngularMeasureValue;
        port mapsIn : ~EnvMapsPort;
        port commandOut : CommandPort;
        port statusIn : ~StatusPort;
        port recordOut : RunRecordPort;
        port settingsIn : ~ScenarioPort;
    }

    part def DisplayAndLog {
        doc /* Browser viewer over the stored run set, plus the run log. */
        attribute storedRuns : Integer = 24;
        port plannerRecordIn : ~RunRecordPort;
        port roverRecordIn : ~RunRecordPort;
        port settingsIn : ~ScenarioPort;
    }

    part def ScenarioConfig {
        doc /* Versioned YAML scenario: start, goal, start time, seed, road preset. */
        attribute scenarioLength : DurationValue default 96 [h];
        attribute startToGoal : LengthValue default 1500 [m];
        attribute initialCharge : Real default 1.0;
        port settingsOut : ScenarioPort;
    }

    // =====================================================================
    // The system of interest, with every interface connected
    // =====================================================================

    part def LunarRoadDemoSystem {
        doc /* Simulates one rover, its route and the assumed effects of a road. */
        part environment : EnvironmentModel;
        part planner : Planner;
        part commLink : CommandDelayLink;
        part rover : RoverModel;
        part display : DisplayAndLog;
        part scenario : ScenarioConfig;

        // Boundary ports: external inputs delegated to the environment model
        port terrainIn : ~TerrainPort;
        port ephemerisIn : ~EphemerisPort;
        bind terrainIn = environment.terrainIn;
        bind ephemerisIn = environment.ephemerisIn;

        // IF-03: environment to planner, link and rover
        interface envToPlanner : 'IF-03 EnvMapsInterface' connect
            source ::> environment.mapsOut to sink ::> planner.mapsIn;
        interface envToLink : 'IF-03 EnvMapsInterface' connect
            source ::> environment.mapsOut to sink ::> commLink.mapsIn;
        interface envToRover : 'IF-03 EnvMapsInterface' connect
            source ::> environment.mapsOut to sink ::> rover.mapsIn;

        // IF-04: planner to rover, through the delay
        interface cmdToLink : 'IF-04 CommandInterface' connect
            source ::> planner.commandOut to sink ::> commLink.commandIn;
        interface cmdToRover : 'IF-04 CommandInterface' connect
            source ::> commLink.commandOut to sink ::> rover.commandIn;

        // IF-05: rover to planner, through the delay
        interface statusToLink : 'IF-05 StatusInterface' connect
            source ::> rover.statusOut to sink ::> commLink.statusIn;
        interface statusToPlanner : 'IF-05 StatusInterface' connect
            source ::> commLink.statusOut to sink ::> planner.statusIn;

        // IF-06: planner and rover to display and log
        interface plannerToLog : 'IF-06 RunRecordInterface' connect
            source ::> planner.recordOut to sink ::> display.plannerRecordIn;
        interface roverToLog : 'IF-06 RunRecordInterface' connect
            source ::> rover.recordOut to sink ::> display.roverRecordIn;

        // IF-07: scenario settings to all blocks
        interface settingsToEnv : 'IF-07 ScenarioInterface' connect
            source ::> scenario.settingsOut to sink ::> environment.settingsIn;
        interface settingsToPlanner : 'IF-07 ScenarioInterface' connect
            source ::> scenario.settingsOut to sink ::> planner.settingsIn;
        interface settingsToRover : 'IF-07 ScenarioInterface' connect
            source ::> scenario.settingsOut to sink ::> rover.settingsIn;
        interface settingsToLink : 'IF-07 ScenarioInterface' connect
            source ::> scenario.settingsOut to sink ::> commLink.settingsIn;
        interface settingsToDisplay : 'IF-07 ScenarioInterface' connect
            source ::> scenario.settingsOut to sink ::> display.settingsIn;
    }

    // =====================================================================
    // Context: the system with its external inputs (IF-01, IF-02)
    // =====================================================================

    part demoContext {
        part terrain : LunarTerrain;
        part ephemeris : SunAndEarthEphemeris;
        part viewer : DemoViewer;
        part sim : LunarRoadDemoSystem;

        interface terrainLink : 'IF-01 TerrainInterface' connect
            source ::> terrain.terrainOut to sink ::> sim.terrainIn;
        interface ephemerisLink : 'IF-02 EphemerisInterface' connect
            source ::> ephemeris.ephemerisOut to sink ::> sim.ephemerisIn;
    }
}

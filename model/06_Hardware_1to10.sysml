package LRD_Hardware {
    doc /*
     * Physical architecture of the 1:10 VIPER-look tabletop rover, and its mapping
     * to VIPER's published electrical blocks.
     * Sources: "Lunar Road Demo: 1:10 VIPER-Look Rover Hardware Design" and
     * "VIPER Electrical Architecture Reconstruction".
     * The model borrows VIPER block names only; it reproduces none of VIPER's design.
     */

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    public import LRD_Structure::*;

    // =====================================================================
    // Ports for the tabletop electrical design (connections E1 to E6)
    // =====================================================================

    port def PowerRail {
        doc /* 4.8 V battery bus, up to about 5.8 V off the charger. */
        out attribute voltage : ElectricPotentialDifferenceValue;
    }
    port def PwmPair      { doc /* 2 PWM lines per motor, plus shared enable (SLP). */ }
    port def MotorCable   { doc /* 6-pin JST-SH: motor power out, 3V3 and ground, encoder A and B back. */ }
    port def I2CBus       { doc /* I2C plus 3V3. */ }
    port def LedDrive     { doc /* One GPIO to a transistor; LEDs run from the battery rail. */ }
    port def WifiLink {
        doc /* Wi-Fi to a laptop; reuses the MVP's IF-04 and IF-05 JSON fields. */
        in item command : Command;
        out item status : RoverStatus;
    }

    // =====================================================================
    // Parts
    // =====================================================================

    part def BatteryBox {
        doc /* 4 AA 2,500 mAh NiMH cells in a switched box. */
        attribute nominalVoltage : ElectricPotentialDifferenceValue = 4.8 [V];
        attribute energy : EnergyValue = 12 [W*h];
        port powerOut : PowerRail;
    }

    part def PicoController {
        doc /* Raspberry Pi Pico 2 W: command, data and control on one board. */
        attribute speedLoopRate : Real default 50.0;   // Hz, assumed
        attribute commsLossTimeout : DurationValue = 1 [s];
        port powerIn : ~PowerRail;
        port pwmDriver1 : PwmPair;
        port pwmDriver2 : PwmPair;
        port imuBus : I2CBus;
        port ledOut : LedDrive;
        port wifi : WifiLink;
    }

    part def MotorDriver {
        doc /* Adafruit DRV8833 breakout, 1.2 A continuous per channel, 2 motors each. */
        attribute continuousCurrentPerChannel : ElectricCurrentValue = 1.2 [A];
        port powerIn : ~PowerRail;
        port pwmIn : ~PwmPair;
        port motorA : MotorCable;
        port motorB : MotorCable;
    }

    part def WheelModule {
        doc /* 1006:1 micro metal gearmotor with Hall encoder and a printed grousered wheel. */
        attribute wheelDiameter : LengthValue = 50 [mm];
        attribute wheelWidth : LengthValue = 20 [mm];
        attribute stallTorqueDerated : TorqueValue = 0.23 [N*m];   // 2.3 kg.cm at 4.8 V
        port cable : ~MotorCable;
    }

    part def Imu {
        doc /* 6-axis IMU breakout; heading by gyro only, so it drifts. */
        port bus : ~I2CBus;
    }

    part def MastLeds {
        doc /* Two white LEDs in the mast; camera holes are dummies. */
        port drive : ~LedDrive;
    }

    part def ChassisTub    { doc /* Load-carrying printed tub, 150 x 118 x 30 mm, 17 mm ground clearance. */ }
    part def BodyShell     { doc /* Cosmetic open-bottom shell with top hatch. */ }
    part def DummyPanel    { doc /* Printed solar panel with a cell grid; no power generation. */ }
    part def Mast          { doc /* T-shaped mast, top at 250 mm. */ }

    part def TabletopRover {
        doc /* 1:10 four-wheel skid-steer model, about 0.6 kg, top speed near 3 cm/s. */

        // Measured or calculated properties checked by the CK-H checks
        attribute footprint : LengthValue = 170 [mm];
        attribute mass : MassValue default 0.6 [kg];
        attribute topSpeed : SpeedValue = 3.0 [cm/s];
        attribute scaleSpeed : SpeedValue = 2 [cm/s];
        attribute drivingPower : PowerValue = 1.48 [W];
        attribute partsCostGBP : Real default 173.70;
        attribute measuredLevelSpeed : SpeedValue;
        attribute continuousRunTime : DurationValue;
        attribute commsLossStopTime : DurationValue;
        attribute maxClimbableSlope : AngularMeasureValue;

        // Structure
        part tub : ChassisTub;
        part shell : BodyShell;
        part panels : DummyPanel[3];
        part mast : Mast;

        // Electrical
        part battery : BatteryBox;
        part controller : PicoController;
        part driver1 : MotorDriver;
        part driver2 : MotorDriver;
        part frontLeft : WheelModule;
        part frontRight : WheelModule;
        part rearLeft : WheelModule;
        part rearRight : WheelModule;
        part imu : Imu;
        part leds : MastLeds;

        port wifi : WifiLink;
        bind wifi = controller.wifi;

        // E1: battery to both drivers directly, and to the Pico's VSYS through a silicon diode
        connection 'E1 battery to driver 1' connect battery.powerOut to driver1.powerIn;
        connection 'E1 battery to driver 2' connect battery.powerOut to driver2.powerIn;
        connection 'E1 battery to Pico VSYS' connect battery.powerOut to controller.powerIn;

        // E2: Pico to drivers, 8 PWM lines and 1 shared enable
        connection 'E2 Pico to driver 1' connect controller.pwmDriver1 to driver1.pwmIn;
        connection 'E2 Pico to driver 2' connect controller.pwmDriver2 to driver2.pwmIn;

        // E3: control board to each wheel over a 6-pin JST-SH cable
        connection 'E3 front left'  connect driver1.motorA to frontLeft.cable;
        connection 'E3 front right' connect driver1.motorB to frontRight.cable;
        connection 'E3 rear left'   connect driver2.motorA to rearLeft.cable;
        connection 'E3 rear right'  connect driver2.motorB to rearRight.cable;

        // E4 and E5
        connection 'E4 Pico to IMU'  connect controller.imuBus to imu.bus;
        connection 'E5 Pico to LEDs' connect controller.ledOut to leds.drive;
    }

    part def RoutePlayerLaptop {
        doc /* Reads a stored route (IF-06 format) and sends waypoints; can add a 6 to 10 s delay. */
        port wifi : ~WifiLink;
    }

    part def OverheadCamera {
        doc /* USB webcam and printed hatch marker for position and heading correction (decision D3). */
    }

    part tabletopDemo {
        part rover : TabletopRover;
        part laptop : RoutePlayerLaptop;
        part camera : OverheadCamera;
        // E6: Pico to laptop over Wi-Fi
        connection 'E6 Wi-Fi link' connect rover.wifi to laptop.wifi;
    }

    // =====================================================================
    // VIPER reference blocks (public sources only; not simulated, not reproduced)
    // =====================================================================

    package ViperReference {
        part def SolarArray       { attribute powerPerPanel : PowerValue = 320 [W]; }
        part def ViperBattery     { attribute capacityStartOfLife : EnergyValue = 5420 [W*h]; }
        part def IntegratedAvionicsUnit { doc /* Command and data handling with electric power functions (Moog). */ }
        part def SEPIA            { doc /* With the IAU, manages solar array, battery charging and power distribution. */ }
        part def MotorControlBox  { doc /* Controls 6 BLDC actuators; 20 A peak per axis for 10 s. */ }
        part def ViperWheelModule { doc /* Drive, steering and suspension actuators. */ }
        part def ViperImu;
        part def StarTracker      { doc /* Rocket Lab ST16RT2; 28 V dual RS-485. */ }
        part def CameraSystem     { doc /* Eight cameras with a Camera Control Unit. */ }
        part def LightSystem      { doc /* Eight LED-array lights with a Light Controller. */ }
        part def XBandLink        { doc /* X-band direct to Earth, gimballed high-gain and fixed low-gain antennas. */ }

        part def ViperRover {
            part solarArrays : SolarArray[3];
            part batteries : ViperBattery[2];
            part iau : IntegratedAvionicsUnit;
            part sepia : SEPIA;
            part motorControlBoxes : MotorControlBox[2];
            part wheelModules : ViperWheelModule[4];
            part imu : ViperImu;
            part starTracker : StarTracker;
            part cameras : CameraSystem;
            part lights : LightSystem;
            part radio : XBandLink;
        }
    }

    // =====================================================================
    // Mapping: which tabletop element stands in for which VIPER block
    // =====================================================================

    part viperReference : ViperReference::ViperRover;
    part tabletopRoverDesign : TabletopRover;

    allocation def StandsInFor {
        doc /* The tabletop element plays the role of the VIPER block in the demo only. */
        end viperBlock : Parts::Part;
        end modelElement : Parts::Part;
    }

    allocation batteryMap : StandsInFor allocate viperReference.batteries to tabletopRoverDesign.battery;
    allocation avionicsMap : StandsInFor allocate viperReference.iau to tabletopRoverDesign.controller;
    allocation powerMgmtMap : StandsInFor allocate viperReference.sepia to tabletopRoverDesign.controller;
    allocation motorCtrlMap1 : StandsInFor allocate viperReference.motorControlBoxes to tabletopRoverDesign.driver1;
    allocation motorCtrlMap2 : StandsInFor allocate viperReference.motorControlBoxes to tabletopRoverDesign.driver2;
    allocation imuMap : StandsInFor allocate viperReference.imu to tabletopRoverDesign.imu;
    allocation starTrackerMap : StandsInFor allocate viperReference.starTracker to tabletopRoverDesign.imu;
    allocation lightsMap : StandsInFor allocate viperReference.lights to tabletopRoverDesign.leds;
    allocation panelsMap : StandsInFor allocate viperReference.solarArrays to tabletopRoverDesign.panels;

    use case def 'Replay Route On Tabletop' {
        subject rover : TabletopRover;
        actor laptop : RoutePlayerLaptop;
        objective {
            doc /* Drive a stored road or no-road route on a printed terrain board at 1:1,000 route scale,
                 * as a physical prop for the simulation results. */
        }
    }
}

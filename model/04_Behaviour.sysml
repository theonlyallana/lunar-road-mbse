package LRD_Behaviour {
    doc /*
     * Functional flow of one simulation run, and the rover's operating modes.
     * The failure conditions come from the spec: charge below reserve, a cell above
     * the slope limit, or no arrival by the end of the scenario.
     */

    public import LRD_Structure::*;

    // =====================================================================
    // One command cycle of a run: scenario in, run record out.
    // A full run repeats the plan, delay and drive steps every 5 min until the
    // rover arrives or fails; status returns to the planner through the delay (IF-05).
    // Not modelled as behaviour: command acknowledgement and resend (REQ-C2.3, C2.6,
    // verified by CK-6) and the minimum 5 min between commands.
    // =====================================================================

    action def RunScenario {
        in item settings : ScenarioSettings;
        out item record : RunRecord;

        action loadScenario {
            in item settings : ScenarioSettings = RunScenario::settings;
            out item config : ScenarioSettings;
        }

        flow from loadScenario.config to computeMaps.config;

        then action computeMaps {
            doc /* Sun and Earth visibility per cell from terrain horizons; road flags from the centreline. */
            in item config : ScenarioSettings;
            out item maps : EnvironmentMaps;
        }

        flow from computeMaps.maps to planRoute.maps;

        then action planRoute {
            doc /* Time-aware plan minimising arrival time plus an energy penalty, within hard limits. */
            in item maps : EnvironmentMaps;
            out item command : Command;
        }

        flow from planRoute.command to delayCommand.commandIn;

        then action delayCommand {
            doc /* Hold the command for half of a sampled 6 to 10 s round trip; optionally drop it. */
            in item commandIn : Command;
            out item commandOut : Command;
        }

        flow from delayCommand.commandOut to driveAndUpdatePower.command;

        then action driveAndUpdatePower {
            doc /* Move with slip, update battery as solar input minus load, and report status. */
            in item command : Command;
            out item status : RoverStatus;
        }

        flow from driveAndUpdatePower.status to logResults.status;

        then action logResults {
            doc /* Record route, state, solar power, load, events and the reported results. */
            in item status : RoverStatus;
            out item record : RunRecord = RunScenario::record;
        }
    }

    // A comparison is the same scenario run twice, changing only the road setting.
    action def RunComparison {
        in item settings : ScenarioSettings;
        action noRoadRun : RunScenario;
        then action roadRun : RunScenario;
    }

    // =====================================================================
    // Rover operating modes
    // =====================================================================

    attribute def CommandReceived;
    attribute def HoldCommanded;
    attribute def WaypointReached;
    attribute def GoalReached;
    attribute def EarthLost;
    attribute def EarthRegained;
    attribute def ChargeBelowReserve;
    attribute def SlopeLimitExceeded;
    attribute def ScenarioTimeout;

    state def RoverModes {
        first start then awaitingCommand;

        state awaitingCommand {
            doc /* No new waypoint starts without a command (REQ-C2.1). */
        }
        accept CommandReceived then driving;
        accept HoldCommanded then holding;
        accept EarthLost then waitingForEarth;
        accept ChargeBelowReserve then failed;
        accept ScenarioTimeout then failed;

        state driving;
        accept WaypointReached then awaitingCommand;
        accept GoalReached then arrived;
        accept ChargeBelowReserve then failed;
        accept SlopeLimitExceeded then failed;
        accept EarthLost then waitingForEarth;
        accept ScenarioTimeout then failed;

        state holding {
            doc /* Planner chose to wait, for example for a moving shadow to pass. */
        }
        accept CommandReceived then driving;
        accept EarthLost then waitingForEarth;
        accept ChargeBelowReserve then failed;
        accept ScenarioTimeout then failed;

        state waitingForEarth {
            doc /* No driving without Earth in view (REQ-R2.2, C2.2). Entered from awaiting a command,
                 * holding or mid-drive; the rover stops until Earth is back in view. */
        }
        accept EarthRegained then awaitingCommand;
        accept ChargeBelowReserve then failed;
        accept ScenarioTimeout then failed;

        state arrived;
        state failed;
    }
}

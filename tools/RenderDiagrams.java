// Loads the model with the SysML v2 Pilot Implementation and writes PlantUML for the
// portfolio diagrams. Run from the repo root with Java 21:
//   java -cp <jupyter-sysml-kernel-all.jar> tools/RenderDiagrams.java <sysml.library dir> diagrams/
// Set GRAPHVIZ_DOT to a recent Graphviz (2.43 fails on interconnection views).
import java.nio.file.*;
import java.util.*;
import org.omg.sysml.interactive.*;

public class RenderDiagrams {
    public static void main(String[] args) throws Exception {
        SysMLInteractive sysml = SysMLInteractive.getInstance();
        sysml.loadLibrary(args[0]);
        try (var files = Files.list(Path.of("model"))) {
            for (Path f : files.filter(p -> p.toString().endsWith(".sysml")).sorted().toList()) {
                SysMLInteractiveResult r = sysml.process(Files.readString(f));
                System.out.println(f.getFileName() + ": " + r.toString().trim());
            }
        }
        // {file name, view, styles (comma separated, may be empty), element names (space separated)}
        String[][] views = {
            {"systemContext", "INTERCONNECTION", "LR,ORTHOLINE", "LRD_Structure::demoContext"},
            {"systemArchitecture", "INTERCONNECTION", "LR,ORTHOLINE", "LRD_Structure::LunarRoadDemoSystem"},
            {"partTree", "TREE", "", "LRD_Structure::LunarRoadDemoSystem"},
            {"runFlow", "ACTION", "", "LRD_Behaviour::RunScenario"},
            {"roverModes", "STATE", "", "LRD_Behaviour::RoverModes"},
            {"simulationRequirements1", "TREE", "LR", "LRD_Requirements_Sim::comparison LRD_Requirements_Sim::reportEitherWay LRD_Requirements_Sim::caveat LRD_Requirements_Sim::assumedValuesConfigurable LRD_Requirements_Sim::fixedScenario LRD_Requirements_Sim::widerTerrainForShadows"},
            {"simulationRequirements2", "TREE", "LR", "LRD_Requirements_Sim::siteAndPatchSelection LRD_Requirements_Sim::r2Framing LRD_Requirements_Sim::precomputedRunSet LRD_Requirements_Sim::displayIndependence LRD_Requirements_Sim::roadSpeedAndSlip LRD_Requirements_Sim::slopeLimit"},
            {"simulationRequirements3", "TREE", "LR", "LRD_Requirements_Sim::headingForSun LRD_Requirements_Sim::loadModel LRD_Requirements_Sim::chargeBounds LRD_Requirements_Sim::visibilityFromTerrain LRD_Requirements_Sim::visibilityHeights LRD_Requirements_Sim::roadOnlyChangesFlags"},
            {"simulationRequirements4", "TREE", "LR", "LRD_Requirements_Sim::delaySampling LRD_Requirements_Sim::commandHandshake LRD_Requirements_Sim::timeAndEnergy LRD_Requirements_Sim::hardLimits LRD_Requirements_Sim::arrivalObjective LRD_Requirements_Sim::planTime"},
            {"roadPresets", "TREE", "", "LRD_Variants::RoadPresetChoices"},
            {"roverElectrical", "INTERCONNECTION", "", "LRD_Hardware::TabletopRover"},
            {"hardwareRequirements", "TREE", "LR", "LRD_Requirements_Hardware::footprintAndWheels LRD_Requirements_Hardware::viperFeatures LRD_Requirements_Hardware::printable LRD_Requirements_Hardware::levelSpeed LRD_Requirements_Hardware::slopeAndTurn LRD_Requirements_Hardware::endurance LRD_Requirements_Hardware::wifiCommanding LRD_Requirements_Hardware::safeStop LRD_Requirements_Hardware::cost LRD_Requirements_Hardware::massLimit LRD_Requirements_Hardware::scaleModelCaveat"},
        };
        Path out = Path.of(args[1]);
        Files.createDirectories(out);
        for (String[] v : views) {
            List<String> styles = v[2].isEmpty() ? List.of() : List.of(v[2].split(","));
            VizResult r = sysml.viz(List.of(v[3].split(" ")), List.of(v[1]), styles, List.of());
            if (r.hasException()) { System.out.println(v[0] + ": " + r.formatException()); continue; }
            if (r.getSVG() != null) {
                Files.writeString(out.resolve(v[0] + ".svg"), r.getSVG());
                System.out.println(v[0] + ": svg");
            } else if (r.getPlantUML() != null) {
                Files.writeString(out.resolve(v[0] + ".puml"), r.getPlantUML());
                System.out.println(v[0] + ": puml");
            } else {
                System.out.println(v[0] + ": " + r);
            }
        }
    }
}

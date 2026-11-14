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
        String[][] views = {
            {"systemContext", "INTERCONNECTION", "LRD_Structure::demoContext"},
            {"systemArchitecture", "INTERCONNECTION", "LRD_Structure::LunarRoadDemoSystem"},
            {"partTree", "TREE", "LRD_Structure::LunarRoadDemoSystem"},
            {"runFlow", "ACTION", "LRD_Behaviour::RunScenario"},
            {"roverModes", "STATE", "LRD_Behaviour::RoverModes"},
            {"simulationRequirements", "TREE", "LRD_Requirements_Sim::simulationSpecification"},
            {"roadPresets", "TREE", "LRD_Variants::RoadPresetChoices"},
            {"roverElectrical", "INTERCONNECTION", "LRD_Hardware::TabletopRover"},
            {"hardwareRequirements", "TREE", "LRD_Requirements_Hardware::hardwareSpecification"},
        };
        Path out = Path.of(args[1]);
        Files.createDirectories(out);
        for (String[] v : views) {
            VizResult r = sysml.viz(List.of(v[2]), List.of(v[1]), List.of(), List.of());
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

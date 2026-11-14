"""Build notebooks/LunarRoadDemo.ipynb for the SysML v2 Jupyter kernel.

One code cell per model file (in load order), then %viz cells that render
the main diagrams. Usage: python3 tools/make_notebook.py
"""
import json
import pathlib

root = pathlib.Path(__file__).resolve().parent.parent
files = sorted((root / "model").glob("*.sysml"))

def md(text):
    return {"cell_type": "markdown", "metadata": {}, "source": text}

def code(text):
    return {"cell_type": "code", "metadata": {}, "execution_count": None, "outputs": [], "source": text}

cells = [md("# Lunar Road Demo: SysML v2 model\n\nRun all cells in order. Each model cell should report the package it created; any error names the line.")]
for f in files:
    cells.append(md(f"## {f.stem}"))
    cells.append(code(f.read_text()))

views = [
    ("System context (IF-01, IF-02)", "INTERCONNECTION", "LRD_Structure::demoContext"),
    ("Logical architecture with IF-03 to IF-07", "INTERCONNECTION", "LRD_Structure::LunarRoadDemoSystem"),
    ("Part tree", "TREE", "LRD_Structure::LunarRoadDemoSystem"),
    ("One simulation run", "ACTION", "LRD_Behaviour::RunScenario"),
    ("Rover operating modes", "STATE", "LRD_Behaviour::RoverModes"),
    ("Simulation requirements", "TREE", "LRD_Requirements_Sim::simulationSpecification"),
    ("Road preset variants", "TREE", "LRD_Variants::RoadPresetChoices"),
    ("1:10 rover electrical design (E1 to E6)", "INTERCONNECTION", "LRD_Hardware::TabletopRover"),
    ("VIPER block to tabletop mapping", "TREE", "LRD_Hardware::viperReference LRD_Hardware::tabletopRoverDesign"),
    ("Hardware requirements", "TREE", "LRD_Requirements_Hardware::hardwareSpecification"),
]
cells.append(md("## Diagrams"))
for title, view, names in views:
    cells.append(md(f"### {title}"))
    cells.append(code(f"%viz --view={view} {names}"))

nb = {
    "cells": cells,
    "metadata": {
        "kernelspec": {"display_name": "SysML", "language": "sysml", "name": "sysml"},
        "language_info": {"name": "SysML"},
    },
    "nbformat": 4,
    "nbformat_minor": 5,
}
out = root / "notebooks" / "LunarRoadDemo.ipynb"
out.parent.mkdir(exist_ok=True)
out.write_text(json.dumps(nb, indent=1))
print(f"Wrote {out} with {len(cells)} cells")

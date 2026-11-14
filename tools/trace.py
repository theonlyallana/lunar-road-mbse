"""Lint the SysML v2 model and build a requirements traceability matrix.

Checks brace balance, that every name used in `require` / `verify` is a
declared requirement, that every requirement has rationale and source metadata,
and that every requirement is verified by at least one check. Writes traceability.csv next to the model folder.

Usage: python3 tools/trace.py model/
"""
import csv
import pathlib
import re
import sys

model_dir = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "model")
files = sorted(model_dir.glob("*.sysml"))
errors = []

req_re = re.compile(r"requirement\s+<'([^']+)'>\s+(\w+)\s*:\s*\w+\s*\{(.*?)\n    \}", re.S)
ver_re = re.compile(r"verification def\s+'([^']+)'\s*\{(.*?)\n    \}", re.S)
kind_re = re.compile(r"kind\s*=\s*\(?([\w,\s]+)\)?;")

requirements = {}   # name -> (id, text, file)
checks = {}         # check -> (methods, [verified names])

for f in files:
    src = f.read_text()
    stripped = re.sub(r"/\*.*?\*/", "", src, flags=re.S)
    stripped = re.sub(r"//.*", "", stripped)
    stripped = re.sub(r"'[^'\n]*'", "''", stripped)
    if stripped.count("{") != stripped.count("}"):
        errors.append(f"{f.name}: unbalanced braces ({stripped.count('{')} open, {stripped.count('}')} close)")
    for rid, name, body in req_re.findall(src):
        doc = re.search(r"doc\s*/\*(.*?)\*/", body, re.S)
        text = " ".join(doc.group(1).replace("*", " ").split()) if doc else ""
        rat = re.search(r'@Rationale\s*\{\s*text\s*=\s*"([^"]*)"', body)
        srcm = re.search(r'@SpecSource\s*\{\s*reference\s*=\s*"([^"]*)";\s*basis\s*=\s*"([^"]*)"', body)
        tbr = "TBR" if "StatusKind::tbr" in body else ""
        requirements[name] = (rid, text, f.name, rat.group(1) if rat else "",
                              srcm.group(1) if srcm else "", srcm.group(2) if srcm else "", tbr)
        if not rat or not srcm:
            errors.append(f"{f.name}: {rid} is missing rationale or source metadata")
    for check, body in ver_re.findall(src):
        kinds = kind_re.search(body)
        methods = ", ".join(k.strip() for k in kinds.group(1).split(",")) if kinds else ""
        checks[check] = (methods, re.findall(r"verify\s+(\w+)\s*;", body))

for f in files:
    for name in re.findall(r"require\s+(\w+)\s*;", f.read_text()):
        if name not in requirements:
            errors.append(f"{f.name}: 'require {name}' has no matching requirement")
for check, (_, names) in checks.items():
    for name in names:
        if name not in requirements:
            errors.append(f"{check}: 'verify {name}' has no matching requirement")

out = model_dir.parent / "traceability.csv"
uncovered = []
with out.open("w", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["Requirement ID", "Name", "Requirement", "Rationale", "Source", "Basis", "Status",
                "Verified by", "Method"])
    def natural(rid):
        return [int(t) if t.isdigit() else t for t in re.split(r"(\d+)", rid)]
    for name, (rid, text, _, rat, ref, basis, tbr) in sorted(requirements.items(), key=lambda kv: natural(kv[1][0])):
        by = [c for c, (_, n) in checks.items() if name in n]
        if not by:
            uncovered.append(rid)
        w.writerow([rid, name, text, rat, ref, basis, tbr, "; ".join(by), "; ".join(checks[c][0] for c in by)])

print(f"{len(files)} files, {len(requirements)} requirements, {len(checks)} verification cases")
print("Unverified requirements:", ", ".join(uncovered) or "none")
print("Errors:" if errors else "No lint errors.")
for e in errors:
    print("  " + e)
print(f"Wrote {out}")
sys.exit(1 if errors else 0)

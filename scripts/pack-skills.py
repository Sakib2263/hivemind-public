#!/usr/bin/env python3
"""Zips each skill in skills/ into skills-packages/<visibility>/<name>.zip
(the zip format claude.ai accepts for upload; any other agent can unzip it).
Started by shortcuts/9 Pack Skills.bat. No dependencies."""
import os, re, shutil, zipfile

kit = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
src, out = os.path.join(kit, "skills"), os.path.join(kit, "skills-packages")
vis, cur = {}, None
for line in open(os.path.join(src, "index.yaml"), encoding="utf-8"):
    m = re.match(r"\s*- name:\s*(\S+)", line)
    if m:
        cur = m.group(1)
    v = re.match(r"\s*visibility:\s*(\S+)", line)
    if cur and v:
        vis[cur] = v.group(1)

shutil.rmtree(out, ignore_errors=True)
for name, v in sorted(vis.items()):
    folder = os.path.join(src, name)
    os.makedirs(os.path.join(out, v), exist_ok=True)
    with zipfile.ZipFile(os.path.join(out, v, name + ".zip"), "w", zipfile.ZIP_DEFLATED) as z:
        for root, _, files in os.walk(folder):
            for f in files:
                p = os.path.join(root, f)
                z.write(p, os.path.join(name, os.path.relpath(p, folder)))
    print(f"{v:10} {name}.zip")
print("\nZips are in skills-packages. shareable = anyone, company = team only, private = never share.")

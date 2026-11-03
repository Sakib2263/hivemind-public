#!/usr/bin/env python3
"""Copies the skills marked `workers: true` in skills/index.yaml into ~/.agents/skills,
where Codex and opencode read them. Only those skill names are replaced; other skills are left alone.
Called by install-rules.sh. No dependencies (reads the simple index format directly)."""
import os, re, shutil, sys

kit = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
src = os.path.join(kit, "skills")
dest = os.path.expanduser("~/.agents/skills")
index = os.path.join(src, "index.yaml")
if not os.path.exists(index):
    sys.exit("[FAIL] missing skills/index.yaml")

names, cur = [], None
for line in open(index, encoding="utf-8"):
    m = re.match(r"\s*- name:\s*(\S+)", line)
    if m:
        cur = m.group(1)
    elif cur and re.match(r"\s*workers:\s*true\b", line):
        names.append(cur)

os.makedirs(dest, exist_ok=True)
for n in names:
    s, d = os.path.join(src, n), os.path.join(dest, n)
    if not os.path.exists(os.path.join(s, "SKILL.md")):
        print("[FAIL] skill missing:", n); continue
    shutil.rmtree(d, ignore_errors=True)   # replace whole folder so deleted files don't linger
    shutil.copytree(s, d)
print(f"[OK]   {len(names)} worker skills in {dest}: {' '.join(names)}")

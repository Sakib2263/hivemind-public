#!/usr/bin/env python3
"""Adds your own skills to Hivemind. Put them in skills/inbox/ first: a skill folder (with SKILL.md),
or a .skill / .zip file (the zip claude.ai and Claude Code use). Each one is checked, moved to
skills/<name>/ and listed in skills/index.yaml, then worker skills are installed.
Started by shortcuts/12 Add My Skills.bat. Your skills are 'private' by default: never exported."""
import os, re, shutil, sys, tempfile, zipfile, subprocess

kit = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
skills, inbox = os.path.join(kit, "skills"), os.path.join(kit, "skills", "inbox")
index = os.path.join(skills, "index.yaml")
tty = sys.stdin.isatty()

def ask(q, default):
    if not tty: return default
    a = input(f"{q} [{default}]: ").strip()
    return a or default

def front(path):
    t = open(path, encoding="utf-8").read()
    m = re.match(r"---\s*\n(.*?)\n---", t, re.S)
    if not m: return None, None
    fm = m.group(1)
    name = re.search(r"^name:\s*[\"']?([^\"'\n]+)", fm, re.M)
    desc = re.search(r"^description:\s*(.*(?:\n[ \t]+.*)*)", fm, re.M)
    d = re.sub(r"\s+", " ", (desc.group(1) if desc else "")).strip(" >|\"'")
    return (name.group(1).strip() if name else None), d

def find_skill_dir(root):
    for dp, _, files in os.walk(root):
        if "SKILL.md" in files: return dp
    return None

os.makedirs(inbox, exist_ok=True)
items = [i for i in sorted(os.listdir(inbox)) if not i.startswith(".")]
if not items:
    print("skills/inbox is empty. Put skill folders or .skill / .zip files there, then run this again."); sys.exit(0)
known = set(re.findall(r"^\s*- name:\s*(\S+)", open(index, encoding="utf-8").read(), re.M))
added = []
for item in items:
    src = os.path.join(inbox, item); tmp = None
    if os.path.isfile(src) and item.lower().endswith((".skill", ".zip")):
        tmp = tempfile.mkdtemp(); zipfile.ZipFile(src).extractall(tmp); sdir = find_skill_dir(tmp)
    elif os.path.isdir(src):
        sdir = find_skill_dir(src)
    else:
        print(f"[SKIP] {item}: not a folder, .skill or .zip"); continue
    if not sdir:
        print(f"[SKIP] {item}: no SKILL.md inside"); continue
    name, desc = front(os.path.join(sdir, "SKILL.md"))
    if not name or not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name) or len(name) > 64:
        print(f"[SKIP] {item}: SKILL.md needs a header with name: lowercase-words-with-hyphens"); continue
    if not desc or len(desc) > 1024:
        print(f"[SKIP] {item}: the description is missing or longer than 1024 characters"); continue
    dest = os.path.join(skills, name)
    if name in known or os.path.exists(dest):
        if ask(f"{name} already exists. Replace it? (y/n)", "n").lower() != "y":
            print(f"[SKIP] {name}: kept the existing one"); continue
        shutil.rmtree(dest, ignore_errors=True)
    shutil.copytree(sdir, dest)
    if name not in known:
        vis = ask(f"{name}: who may see it? private / company / shareable", "private")
        if vis not in ("private", "company", "shareable"): vis = "private"
        workers = ask(f"{name}: install it for the coding workers too? (y/n)", "n").lower() == "y"
        use = desc[:200].replace('"', "'")
        with open(index, "a", encoding="utf-8") as f:
            f.write(f'\n  - name: {name}\n    path: {name}/SKILL.md\n    category: mine\n    use_when: "{use}"\n'
                    f'    visibility: {vis}\n    workers: {"true" if workers else "false"}\n    depends_on: []\n')
        known.add(name)
    shutil.rmtree(src) if os.path.isdir(src) else os.remove(src)
    if tmp: shutil.rmtree(tmp, ignore_errors=True)
    added.append(name); print(f"[OK]   {name}")
print(f"\nAdded {len(added)} skill(s). They are listed in skills/index.yaml.")
subprocess.run([sys.executable, os.path.join(kit, "scripts", "install-skills.py")])

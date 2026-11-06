#!/usr/bin/env python3
"""Make a small map of a Godot project to paste into AI chats.

Usage:
    python tools/repo_map.py                      # map of the current folder
    python tools/repo_map.py path/to/project      # map of another folder
    python tools/repo_map.py --full a.gd b.gd     # map + full text of listed files

Output goes to the screen. Save it with:  python tools/repo_map.py > repo_map.txt
"""
import os
import re
import sys

SKIP_DIRS = {".git", ".godot", ".import", "addons", "builds", "node_modules", "__pycache__", "assets"}
SHOW_EXT = {".gd", ".tscn", ".json", ".md", ".csv", ".tres", ".cfg", ".godot", ".py", ".yml", ".yaml"}

RE_CLASS = re.compile(r"^class_name\s+(\w+)")
RE_EXTENDS = re.compile(r"^extends\s+(\S+)")
RE_SIGNAL = re.compile(r"^signal\s+(\w+(?:\(.*\))?)")
RE_FUNC = re.compile(r"^(static\s+)?func\s+(\w+)\s*\((.*?)\)\s*(->\s*[\w\.\[\]]+)?\s*:")
RE_CONST = re.compile(r"^const\s+(\w+)")
RE_DOC = re.compile(r"^##\s?(.*)")


def summarize_gd(path):
    """Return a list of short lines describing one GDScript file."""
    out = []
    try:
        with open(path, encoding="utf-8") as f:
            lines = f.read().splitlines()
    except (OSError, UnicodeDecodeError) as err:
        return ["  (cannot read: %s)" % err]
    doc = ""
    consts = 0
    for line in lines:
        m = RE_DOC.match(line)
        if m and not doc:
            doc = m.group(1).strip()
        m = RE_CLASS.match(line)
        if m:
            out.append("  class_name %s" % m.group(1))
            continue
        m = RE_EXTENDS.match(line)
        if m:
            out.append("  extends %s" % m.group(1))
            continue
        m = RE_SIGNAL.match(line)
        if m:
            out.append("  signal %s" % m.group(1))
            continue
        if RE_CONST.match(line):
            consts += 1
            continue
        m = RE_FUNC.match(line)
        if m:
            static = "static " if m.group(1) else ""
            ret = " " + m.group(4) if m.group(4) else ""
            out.append("  %sfunc %s(%s)%s" % (static, m.group(2), m.group(3), ret))
    if consts:
        out.append("  consts: %d" % consts)
    if doc:
        out.insert(0, "  # " + doc)
    out.append("  lines: %d" % len(lines))
    return out


def walk(root):
    """Print the folder tree and a summary for each .gd file."""
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        rel = os.path.relpath(dirpath, root)
        depth = 0 if rel == "." else rel.count(os.sep) + 1
        if rel != ".":
            print("%s%s/" % ("  " * (depth - 1), os.path.basename(dirpath)))
        for name in sorted(filenames):
            ext = os.path.splitext(name)[1]
            if ext not in SHOW_EXT:
                continue
            indent = "  " * depth
            print("%s%s" % (indent, name))
            if ext == ".gd":
                for line in summarize_gd(os.path.join(dirpath, name)):
                    print(indent + line)


def dump_full(paths):
    """Print the full text of the listed files."""
    for p in paths:
        print("\n" + "=" * 60)
        print("FILE: %s" % p)
        print("=" * 60)
        try:
            with open(p, encoding="utf-8") as f:
                print(f.read())
        except (OSError, UnicodeDecodeError) as err:
            print("(cannot read: %s)" % err)


def main(argv):
    full = []
    root = "."
    if "--full" in argv:
        i = argv.index("--full")
        full = argv[i + 1:]
        argv = argv[:i]
    if len(argv) > 1:
        root = argv[1]
    if not os.path.isdir(root):
        print("Folder not found: %s" % root)
        return 1
    print("# REPO MAP of %s" % os.path.abspath(root))
    walk(root)
    if full:
        dump_full(full)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

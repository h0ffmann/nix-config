#!/usr/bin/env python3
"""Write site/static/history.json: every commit on main, grouped into eras, plus the labs' cards.

Run from a full clone (a shallow one drops the early eras): python3 site/history.py
"""
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPO = "https://github.com/h0ffmann/picasso"

# (first PR of the era, title, blurb); a commit belongs to the last era whose first PR it reached.
ERAS = [
    (0, "sic mundus", "A NixOS desktop from scratch: Home Manager, DaVinci Resolve, Obsidian, a "
        "Python/uv dev shell. The PRs are named after songs."),
    (8, "the workstation", "Cachix, flake dev shells, a compilation profile, repomix for code "
        "quality, aider, Ollama and Bazel, Steam, Haskell, Helix and Python 3.13."),
    (30, "the labs", "The system becomes a set of self-contained flakes other repos borrow: "
         "pratico (WAVEWATCH III), publisher and its Action, lint, agentic, cuda, present; "
         "CI per lab, lab.json cards, AGENTS.md, the MIT licence."),
    (68, "back to NixOS", "The root moves to nixos-26.05 to run NixOS again: a lighter system, "
         "a VM to try it first, vendored Nix skills, mcp-nixos, graphify, the cuda doctor. "
         "nix-config is renamed picasso."),
]


def git(*args):
    return subprocess.run(["git", "-C", str(ROOT), *args], check=True, capture_output=True,
                          text=True).stdout


def commits():
    out = git("log", "--reverse", "--first-parent", "main", "--numstat",
              "--format=%x1e%H%x1f%ad%x1f%an%x1f%s", "--date=short")
    for block in filter(None, out.split("\x1e")):
        head, *stat = block.strip("\n").split("\n")
        sha, date, author, subject = head.split("\x1f")
        added = deleted = files = 0
        for line in filter(None, stat):
            a, d, _ = line.split("\t", 2)
            files += 1
            added += int(a) if a.isdigit() else 0
            deleted += int(d) if d.isdigit() else 0
        pr = re.search(r"\(#(\d+)\)$", subject) or re.match(r"Merge pull request #(\d+)", subject)
        scope = re.match(r"\w+\(([\w/-]+)\)", subject)
        yield {
            "sha": sha[:7], "date": date, "subject": subject,
            "pr": int(pr.group(1)) if pr else None,
            "scope": scope.group(1) if scope else None,
            "bot": author.endswith("[bot]"),
            "files": files, "added": added, "deleted": deleted,
        }


def main():
    eras = [{"title": t, "blurb": b, "commits": []} for _, t, b in ERAS]
    last_pr = 0
    for c in commits():
        last_pr = c["pr"] or last_pr
        index = max(i for i, (first, _, _) in enumerate(ERAS) if last_pr >= first)
        eras[index]["commits"].append(c)
    for era in eras:
        era["from"], era["to"] = era["commits"][0]["date"], era["commits"][-1]["date"]
    labs = {p.parent.name: json.loads(p.read_text())["summary"]
            for p in sorted(ROOT.glob("labs/*/lab.json"))}
    out = {"repo": REPO, "formerly": "nix-config", "labs": labs, "eras": eras}
    path = ROOT / "site" / "static" / "history.json"
    path.write_text(json.dumps(out, indent=1, ensure_ascii=False) + "\n")
    total = sum(len(e["commits"]) for e in eras)
    print(f"{path.relative_to(ROOT)}: {total} commits in {len(eras)} eras, {len(labs)} labs")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Write dist/releases.json from the repo's v* tags: the latest version, what is unreleased on HEAD,
and a changelog per release grouped by commit type. Run by `just build`; generated, never committed,
because a release must not need a commit after its tag. A clone without tags (CI's shallow
checkout) gets no version and an empty changelog.

  python3 releases.py [out]      # default dist/releases.json
  python3 releases.py --self-test
"""
import json
import pathlib
import re
import subprocess
import sys

SITE = pathlib.Path(__file__).resolve().parent
REPO = "https://github.com/h0ffmann/picasso"
SEMVER = re.compile(r"^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
GROUPS = [("feat", "Features"), ("fix", "Fixes"), ("docs", "Documentation")]
OTHER = "Other changes"


def git(*args):
    return subprocess.run(["git", "-C", str(SITE), *args], capture_output=True, text=True).stdout


def entry(subject):
    """`feat(site)!: x (#92)` -> (group title, {"subject": "site: x", "pr": 92, "breaking": True})."""
    pr = re.search(r" \(#(\d+)\)$", subject)
    text = subject[:pr.start()] if pr else subject
    m = re.match(r"^(\w+)(?:\(([^)]*)\))?(!)?: (.*)$", text)
    kind, scope, bang, text = (m.group(1), m.group(2), m.group(3), m.group(4)) if m else ("", None, None, text)
    title = dict(GROUPS).get(kind, OTHER)
    return title, {"subject": f"{scope}: {text}" if scope else text,
                   "pr": int(pr.group(1)) if pr else None, "breaking": bool(bang)}


def grouped(rev_range):
    out = git("log", "--first-parent", "--format=%an%x1f%s", rev_range)
    groups = {}
    for line in filter(None, out.split("\n")):
        author, subject = line.split("\x1f", 1)
        if author.endswith("[bot]"):
            continue
        title, e = entry(subject)
        groups.setdefault(title, []).append(e)
    order = [t for _, t in GROUPS] + [OTHER]
    return [{"title": t, "entries": groups[t]} for t in order if t in groups]


def build():
    refs = git("for-each-ref", "--sort=-v:refname", "--format=%(refname:short) %(creatordate:short)",
               "refs/tags/v*")
    tags = [line.split() for line in refs.split("\n") if line and SEMVER.match(line.split()[0])]
    releases = []
    for i, (tag, date) in enumerate(tags):
        previous = tags[i + 1][0] if i + 1 < len(tags) else None
        releases.append({"tag": tag, "date": date, "previous": previous,
                         "groups": grouped(f"{previous}..{tag}" if previous else tag)})
    version = tags[0][0] if tags else None
    unreleased = grouped(f"{version}..HEAD") if version else []
    return {"repo": REPO, "version": version, "unreleased": unreleased, "releases": releases}


def self_test():
    assert entry("feat(site): port the site to Gleam and Lustre (#92)") == (
        "Features", {"subject": "site: port the site to Gleam and Lustre", "pr": 92, "breaking": False})
    assert entry("feat(lint)!: drop ruff") == ("Features", {"subject": "lint: drop ruff", "pr": None, "breaking": True})
    assert entry("docs: a logo (#83)")[0] == "Documentation"
    assert entry("chore: bump (#68)")[0] == OTHER
    assert entry("picasso: the site (#81)") == (OTHER, {"subject": "the site", "pr": 81, "breaking": False})
    assert entry("Merge pull request #5 from x")[0] == OTHER
    assert all(SEMVER.match(t) for t in ("v0.1.0", "v10.0.3")) and not any(
        SEMVER.match(t) for t in ("v0.1", "v01.0.0", "v1.0.0-rc1"))
    print("releases.py: self-test ok")


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        self_test()
    else:
        out = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else SITE / "dist" / "releases.json"
        data = build()
        out.write_text(json.dumps(data, indent=1, ensure_ascii=False) + "\n")
        print(f"{out.name}: version {data['version'] or 'none'}, {len(data['releases'])} releases")

#!/usr/bin/env python3
"""social — every docs/social/instagram_*/README.md carries a status, and a post that is POSTED
on Instagram goes to Threads with the same slides, caption and alt texts (docs/adr/0001).

The front matter of each post README:

    ---
    status: POSTED                                  # DESIGN | REVIEW | POSTED
    instagram: https://www.instagram.com/p/<id>/    # required when POSTED
    caption: pt-BR                                  # which "## Caption (<lang>)" block was posted
    ---

    scripts/social.py check                         # every post has a valid front matter
    scripts/social.py changed <before-sha> <sha>    # posts that became POSTED between two commits
    scripts/social.py latest                        # the newest POSTED post
    scripts/social.py post <dir> --sha <sha> [--dry-run]
    scripts/social.py release <tag> [--dry-run]     # a text post for a vMAJOR.MINOR.PATCH release
    scripts/social.py refresh                       # print a refreshed long-lived Threads token
    scripts/social.py --self-test

`post` reads THREADS_USER_ID and THREADS_ACCESS_TOKEN from the environment. Threads cannot take
an upload, only a public URL, so the slides are fetched from raw.githubusercontent.com at <sha>.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOCIAL = ROOT / "docs" / "social"
REPO = "h0ffmann/picasso"
API = "https://graph.threads.net/v1.0"
STATUSES = ("DESIGN", "REVIEW", "POSTED")
# Threads counts an emoji by its UTF-8 length, so bytes is the safe measure.
TEXT_LIMIT = 500
CAROUSEL_MAX = 20
CONCEPT_DOI = "10.5281/zenodo.23311208"


class PostError(Exception):
    pass


def front_matter(text: str) -> dict[str, str]:
    m = re.match(r"---\n(.*?)\n---\n", text, re.DOTALL)
    if not m:
        return {}
    fields = {}
    for line in m.group(1).splitlines():
        key, sep, value = line.partition(":")
        if sep:
            fields[key.strip()] = value.strip()
    return fields


def problems(text: str) -> list[str]:
    fm = front_matter(text)
    if not fm:
        return ["no front matter (--- status: ... ---) at the top"]
    out = []
    status = fm.get("status", "")
    if status not in STATUSES:
        out.append(f"status is {status!r}, not one of {', '.join(STATUSES)}")
    if status == "POSTED":
        if not re.fullmatch(r"https://www\.instagram\.com/p/[\w-]+/?", fm.get("instagram", "")):
            out.append("POSTED needs instagram: https://www.instagram.com/p/<id>/")
        lang = fm.get("caption", "")
        if not lang or caption(text, lang) is None:
            out.append(f"caption: {lang!r} names no '## Caption ({lang})' text block")
        elif len(caption(text, lang).encode()) > TEXT_LIMIT:
            out.append(f"the {lang} caption is longer than Threads' {TEXT_LIMIT} bytes")
    return out


def caption(text: str, lang: str) -> str | None:
    m = re.search(r"^## Caption \(" + re.escape(lang) + r"\)\n+```text\n(.*?)\n```", text, re.DOTALL | re.MULTILINE)
    return m.group(1).strip() if m else None


def alt_texts(text: str) -> dict[int, str]:
    m = re.search(r"^## Alt text\n(.*?)(?=^## |\Z)", text, re.DOTALL | re.MULTILINE)
    if not m:
        return {}
    return {int(n): t.strip() for n, t in re.findall(r"^(\d+)\. (.+)$", m.group(1), re.MULTILINE)}


def slides(post: Path) -> list[Path]:
    return sorted(post.glob("slide-*.png"), key=lambda p: int(re.sub(r"\D", "", p.stem) or 0))


def posts(root: Path = SOCIAL) -> list[Path]:
    return sorted(p for p in root.glob("instagram_*") if p.is_dir())


def git_show(rev: str, path: str) -> str:
    r = subprocess.run(["git", "-C", str(ROOT), "show", f"{rev}:{path}"], capture_output=True, text=True, check=False)
    return r.stdout if r.returncode == 0 else ""


def became_posted(before_text: str, after_text: str) -> bool:
    return front_matter(after_text).get("status") == "POSTED" and front_matter(before_text).get("status") != "POSTED"


def changed(before: str, after: str) -> list[str]:
    if not before or set(before) == {"0"}:
        print("social: no previous commit to compare with; post by hand with workflow_dispatch", file=sys.stderr)
        return []
    out = []
    for post in posts():
        rel = post.relative_to(ROOT).as_posix() + "/README.md"
        if became_posted(git_show(before, rel), git_show(after, rel)):
            out.append(post.relative_to(ROOT).as_posix())
    return out


def latest() -> str | None:
    done = [p for p in posts() if front_matter((p / "README.md").read_text()).get("status") == "POSTED"]
    return done[-1].relative_to(ROOT).as_posix() if done else None


class Threads:
    def __init__(self, user: str, token: str, wait: float = 5, tries: int = 60):
        self.user, self.token, self.wait, self.tries = user, token, wait, tries

    def call(self, method: str, path: str, params: dict[str, str]) -> dict:
        params = {**params, "access_token": self.token}
        data = urllib.parse.urlencode(params).encode()
        url = f"{API}/{path}"
        if method == "GET":
            url, data = f"{url}?{data.decode()}", None
        req = urllib.request.Request(url, data=data, method=method)
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            # the body says why (expired token, link limit, ...); the URL holds the token, so not it
            raise PostError(f"{method} {path}: HTTP {e.code} {e.read().decode(errors='replace')}") from None

    def container(self, params: dict[str, str]) -> str:
        cid = self.call("POST", f"{self.user}/threads", params)["id"]
        # Meta asks for a wait until the container is processed before it is published.
        for _ in range(self.tries):
            st = self.call("GET", cid, {"fields": "status,error_message"})
            if st.get("status") == "FINISHED":
                return cid
            if st.get("status") in ("ERROR", "EXPIRED"):
                raise PostError(f"container {cid}: {st.get('status')} {st.get('error_message', '')}")
            time.sleep(self.wait)
        raise PostError(f"container {cid} not FINISHED after {self.tries} checks")

    def publish(self, text: str, images: list[tuple[str, str]], link: str = "") -> str:
        if not images:
            # a link preview card exists only on text posts
            cid = self.container({"media_type": "TEXT", "text": text, **({"link_attachment": link} if link else {})})
        elif len(images) == 1:
            url, alt = images[0]
            cid = self.container({"media_type": "IMAGE", "image_url": url, "alt_text": alt, "text": text})
        else:
            children = [
                self.container({"media_type": "IMAGE", "image_url": url, "alt_text": alt, "is_carousel_item": "true"})
                for url, alt in images
            ]
            cid = self.container({"media_type": "CAROUSEL", "children": ",".join(children), "text": text})
        mid = self.call("POST", f"{self.user}/threads_publish", {"creation_id": cid})["id"]
        return self.call("GET", mid, {"fields": "permalink"}).get("permalink", f"media {mid}")


def plan(post: Path, sha: str) -> tuple[str, list[tuple[str, str]]]:
    text = (post / "README.md").read_text()
    bad = problems(text)
    if bad:
        raise PostError(f"{post.name}: " + "; ".join(bad))
    if front_matter(text)["status"] != "POSTED":
        raise PostError(f"{post.name}: not POSTED on Instagram yet")
    alts = alt_texts(text)
    rel = post.relative_to(ROOT).as_posix()
    files = slides(post)
    if len(files) > CAROUSEL_MAX:
        raise PostError(f"{post.name}: {len(files)} slides, Threads takes at most {CAROUSEL_MAX}")
    images = [
        (f"https://raw.githubusercontent.com/{REPO}/{sha}/{rel}/{f.name}", alts.get(i, "")[:1000])
        for i, f in enumerate(files, 1)
    ]
    return caption(text, front_matter(text)["caption"]) or "", images


def post_cmd(post: Path, sha: str, dry_run: bool) -> int:
    text, images = plan(post, sha)
    if dry_run:
        print(json.dumps({"post": post.name, "text": text, "images": images}, ensure_ascii=False, indent=2))
        return 0
    link = client().publish(text, images)
    print(f"{post.name} on Threads: {link}")
    return 0


def release_text(tag: str) -> tuple[str, str]:
    if not re.fullmatch(r"v\d+\.\d+\.\d+", tag):
        raise PostError(f"{tag!r} is not a vMAJOR.MINOR.PATCH tag")
    url = f"https://github.com/{REPO}/releases/tag/{tag}"
    text = (
        f"picasso {tag} saiu. Labs Nix que fixam a toolchain como qualquer dependência.\n\n"
        f"Notas: {url}\nDOI: https://doi.org/{CONCEPT_DOI}\nSite: https://h0ffmann.github.io/picasso\n\n"
        "#nix #nixos #reproducibility #opensource"
    )
    return text, url


def release_cmd(tag: str, dry_run: bool) -> int:
    text, url = release_text(tag)
    if dry_run:
        print(text)
        return 0
    print(f"picasso {tag} on Threads: {client().publish(text, [], link=url)}")
    return 0


def client() -> Threads:
    user, token = os.environ.get("THREADS_USER_ID", ""), os.environ.get("THREADS_ACCESS_TOKEN", "")
    if not user or not token:
        raise PostError("THREADS_USER_ID and THREADS_ACCESS_TOKEN must be set (repository secrets)")
    return Threads(user, token)


def refresh() -> int:
    token = os.environ.get("THREADS_ACCESS_TOKEN", "")
    if not token:
        raise PostError("THREADS_ACCESS_TOKEN must be set")
    q = urllib.parse.urlencode({"grant_type": "th_refresh_token", "access_token": token})
    with urllib.request.urlopen(f"https://graph.threads.net/refresh_access_token?{q}", timeout=60) as r:
        body = json.load(r)
    print(f"social: new token valid for {int(body['expires_in']) // 86400} days", file=sys.stderr)
    print(body["access_token"])
    return 0


def check() -> int:
    bad = 0
    for post in posts():
        for p in problems((post / "README.md").read_text()):
            print(f"{post.relative_to(ROOT)}/README.md: {p}", file=sys.stderr)
            bad += 1
    print(f"social: {len(posts())} posts checked, {bad} problems")
    return 1 if bad else 0


SAMPLE = """---
status: POSTED
instagram: https://www.instagram.com/p/AbC_1-x/
caption: pt-BR
---

# sample

## Caption (pt-BR)

```text
Olá, Threads ✨
```

## Alt text

1. First slide.
2. Second slide.

## Render again
"""


def self_test() -> int:
    assert front_matter(SAMPLE)["status"] == "POSTED"
    assert problems(SAMPLE) == [], problems(SAMPLE)
    assert caption(SAMPLE, "pt-BR") == "Olá, Threads ✨"
    assert alt_texts(SAMPLE) == {1: "First slide.", 2: "Second slide."}
    assert problems("# no front matter\n")
    assert problems(SAMPLE.replace("POSTED", "DONE"))
    assert problems(SAMPLE.replace("https://www.instagram.com/p/AbC_1-x/", ""))
    assert problems(SAMPLE.replace("caption: pt-BR", "caption: en"))
    assert problems(SAMPLE.replace("Olá, Threads ✨", "é" * 251))
    assert problems(SAMPLE.replace("status: POSTED", "status: DESIGN").replace("instagram: ", "x: ")) == []
    assert became_posted("", SAMPLE)
    assert became_posted(SAMPLE.replace("POSTED", "REVIEW"), SAMPLE)
    assert not became_posted(SAMPLE, SAMPLE)
    assert not became_posted("", SAMPLE.replace("POSTED", "REVIEW"))

    with tempfile.TemporaryDirectory() as d:
        post = Path(d) / "instagram_009"
        post.mkdir()
        (post / "README.md").write_text(SAMPLE)
        for n in (10, 2, 1):
            (post / f"slide-{n}.png").write_bytes(b"")
        assert [p.name for p in slides(post)] == ["slide-1.png", "slide-2.png", "slide-10.png"]

    calls: list[tuple[str, str, dict]] = []

    class Fake(Threads):
        def call(self, method, path, params):
            calls.append((method, path, params))
            if path.endswith("/threads"):
                return {"id": f"c{len(calls)}"}
            if path.endswith("/threads_publish"):
                return {"id": "m1"}
            if params.get("fields") == "permalink":
                return {"permalink": "https://www.threads.com/@x/post/1"}
            return {"status": "FINISHED"}

    link = Fake("42", "t", wait=0).publish("hi", [("u1", "a1"), ("u2", "a2")])
    assert link == "https://www.threads.com/@x/post/1"
    made = [p for m, path, p in calls if path == "42/threads"]
    assert [p["media_type"] for p in made] == ["IMAGE", "IMAGE", "CAROUSEL"]
    assert all(p.get("is_carousel_item") == "true" for p in made[:2])
    assert made[2]["text"] == "hi" and made[2]["children"].count(",") == 1
    carousel_id = f"c{next(i for i, c in enumerate(calls, 1) if c[2] is made[2])}"
    assert [c[2]["creation_id"] for c in calls if c[1] == "42/threads_publish"] == [carousel_id]

    calls.clear()
    Fake("42", "t", wait=0).publish("only text", [])
    assert calls[0][2] == {"media_type": "TEXT", "text": "only text"}

    class Broken(Fake):
        def call(self, method, path, params):
            if params.get("fields") == "status,error_message":
                return {"status": "ERROR", "error_message": "bad image"}
            return super().call(method, path, params)

    try:
        Broken("42", "t", wait=0).publish("x", [("u", "a")])
        raise AssertionError("an ERROR container must stop the post")
    except PostError as e:
        assert "bad image" in str(e)

    text, url = release_text("v1.2.3")
    assert url.endswith("/releases/tag/v1.2.3") and len(text.encode()) <= TEXT_LIMIT
    assert text.count("https://") <= 5  # Threads refuses more than five distinct links
    try:
        release_text("1.2")
        raise AssertionError("a tag that is not vMAJOR.MINOR.PATCH must be refused")
    except PostError:
        pass
    calls.clear()
    Fake("42", "t", wait=0).publish("rel", [], link="https://x")
    assert calls[0][2]["link_attachment"] == "https://x"

    assert check() == 0, "a post README in this repo is invalid"
    print("social: self-test passed")
    return 0


def main(argv: list[str]) -> int:
    try:
        match argv:
            case ["--self-test"]:
                return self_test()
            case ["check"]:
                return check()
            case ["changed", before, after]:
                print("\n".join(changed(before, after)))
                return 0
            case ["latest"]:
                print(latest() or "")
                return 0
            case ["post", d, "--sha", sha, *rest] if rest in ([], ["--dry-run"]):
                return post_cmd(ROOT / d, sha, bool(rest))
            case ["release", tag, *rest] if rest in ([], ["--dry-run"]):
                return release_cmd(tag, bool(rest))
            case ["refresh"]:
                return refresh()
        print(__doc__, file=sys.stderr)
        return 2
    except PostError as e:
        print(f"social: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

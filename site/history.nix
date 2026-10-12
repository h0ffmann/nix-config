# static/history.json: every commit on main, grouped into eras, plus the labs' cards. Nix cannot
# run git, so `just history` passes the log in a file (the format is in the justfile); run it from
# a full clone, since a shallow one drops the early eras.
{ logFile ? null
, log ? builtins.readFile logFile
, labs ? builtins.listToAttrs (map
    (name: { inherit name; value = (builtins.fromJSON (builtins.readFile (../labs + "/${name}/lab.json"))).summary; })
    (builtins.filter (name: builtins.pathExists (../labs + "/${name}/lab.json")) (builtins.attrNames (builtins.readDir ../labs))))
}:
let
  inherit (builtins) elemAt filter foldl' genList head isString length map match split tail;

  splitOn = re: s: filter isString (split re s);
  num = s: if match "[0-9]+" s != null then builtins.fromJSON s else 0;
  sum = foldl' (a: b: a + b) 0;
  last = l: elemAt l (length l - 1);
  firstGroup = m: if m == null then null else head m;

  # (first PR of the era, title, blurb); a commit belongs to the last era whose first PR it reached.
  eras = [
    {
      first = 0;
      title = "sic mundus";
      blurb = "A NixOS desktop from scratch: Home Manager, DaVinci Resolve, Obsidian, a "
        + "Python/uv dev shell. The PRs are named after songs.";
    }
    {
      first = 8;
      title = "the workstation";
      blurb = "Cachix, flake dev shells, a compilation profile, repomix for code "
        + "quality, aider, Ollama and Bazel, Steam, Haskell, Helix and Python 3.13.";
    }
    {
      first = 30;
      title = "the labs";
      blurb = "The system becomes a set of self-contained flakes other repos borrow: "
        + "pratico (WAVEWATCH III), publisher and its Action, lint, agentic, cuda, present; "
        + "CI per lab, lab.json cards, AGENTS.md, the MIT licence.";
    }
    {
      first = 68;
      title = "back to NixOS";
      blurb = "The root moves to nixos-26.05 to run NixOS again: a lighter system, "
        + "a VM to try it first, vendored Nix skills, mcp-nixos, graphify, the cuda doctor. "
        + "nix-config is renamed picasso.";
    }
  ];

  commit = block:
    let
      lines = filter (l: l != "") (splitOn "\n" block);
      fields = splitOn "\t" (head lines);
      subject = builtins.concatStringsSep "\t" (genList (i: elemAt fields (i + 3)) (length fields - 3));
      stat = map (splitOn "\t") (tail lines);
    in
    {
      sha = builtins.substring 0 7 (elemAt fields 0);
      date = elemAt fields 1;
      inherit subject;
      pr =
        let m = match ".*\\(#([0-9]+)\\)" subject; mm = match "Merge pull request #([0-9]+).*" subject; in
        if m != null then num (head m) else if mm != null then num (head mm) else null;
      scope = firstGroup (match "[A-Za-z0-9_]+\\(([A-Za-z0-9_/-]+)\\).*" subject);
      bot = match ".*\\[bot]" (elemAt fields 2) != null;
      files = length stat;
      added = sum (map (s: num (elemAt s 0)) stat);
      deleted = sum (map (s: num (elemAt s 1)) stat);
    };

  commits = map commit (filter (b: b != "") (splitOn "(^|\n)@@@" log));

  # Each commit carries the era index; the PR number sticks until the next commit that has one.
  placed = (foldl'
    (acc: c:
      let lastPr = if c.pr != null then c.pr else acc.lastPr; in
      {
        inherit lastPr;
        out = acc.out ++ [{
          era = last (filter (i: lastPr >= (elemAt eras i).first) (genList (i: i) (length eras)));
          inherit c;
        }];
      })
    { lastPr = 0; out = [ ]; }
    commits).out;

  grouped = genList
    (i:
      let cs = map (p: p.c) (filter (p: p.era == i) placed); era = elemAt eras i; in
      {
        inherit (era) title blurb;
        commits = cs;
        from = (head cs).date;
        to = (last cs).date;
      })
    (length eras);

  data = { repo = "https://github.com/h0ffmann/picasso"; formerly = "nix-config"; inherit labs; eras = grouped; };

  # Python's json.dumps(indent=1, ensure_ascii=False), in the order the site's file always had.
  order = [ "repo" "formerly" "labs" "eras" "title" "blurb" "commits" "from" "to" "sha" "date" "subject" "pr" "scope" "bot" "files" "added" "deleted" ];
  rank = k: let r = filter (i: elemAt order i == k) (genList (i: i) (length order)); in if r == [ ] then length order else head r;
  keys = a: builtins.sort (x: y: let rx = rank x; ry = rank y; in if rx == ry then x < y else rx < ry) (builtins.attrNames a);
  pad = n: builtins.concatStringsSep "" (genList (_: " ") n);
  pretty = n: v:
    if builtins.isAttrs v then
      if v == { } then "{}" else
      "{\n" + builtins.concatStringsSep ",\n"
        (map (k: pad (n + 1) + builtins.toJSON k + ": " + pretty (n + 1) v.${k}) (keys v))
      + "\n" + pad n + "}"
    else if builtins.isList v then
      if v == [ ] then "[]" else
      "[\n" + builtins.concatStringsSep ",\n" (map (x: pad (n + 1) + pretty (n + 1) x) v) + "\n" + pad n + "]"
    else builtins.toJSON v;
in
{
  inherit data;
  json = pretty 0 data + "\n";
  summary = "site/static/history.json: ${toString (length commits)} commits in "
    + "${toString (length grouped)} eras, ${toString (length (builtins.attrNames labs))} labs\n";
}

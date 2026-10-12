"""Counts GitHub-reviewed advisories with a CVE id per month for npm and PyPI, from OSV's dumps.

    curl -O https://osv-vulnerabilities.storage.googleapis.com/npm/all.zip   (and PyPI/all.zip)
    python3 cves.py <dir with npm.zip and PyPI.zip> > cves.json

OSV carries the GitHub Advisory Database as GHSA-* records; "published" is GitHub's date.
"""
import collections
import datetime
import json
import sys
import zipfile

out = {"source": "OSV dumps of the GitHub Advisory Database (GHSA-* records with a CVE alias)",
       "fetched": datetime.datetime.now(datetime.UTC).date().isoformat(), "monthly": {}}
for eco in ["npm", "PyPI"]:
    months = collections.Counter()
    with zipfile.ZipFile(f"{sys.argv[1]}/{eco}.zip") as z:
        for name in z.namelist():
            v = json.loads(z.read(name))
            if v["id"].startswith("GHSA-") and any(a.startswith("CVE-") for a in v.get("aliases", [])):
                months[v["published"][:7]] += 1
    out["monthly"][eco] = dict(sorted(months.items()))
json.dump(out, sys.stdout, indent=1)
print()

---
title: "Quickstart: the owner's steps"
status: draft
date: 2026-10-12
related: [spec.md, plan.md, tasks.md]
---

# Quickstart: the owner's steps

Only the owner of `h0ffmann` and `ouroboric-dev` can take these steps. An agent never does them.
Each step says where to go and how to check it worked. The agent work happens between steps 3
and 4 ([tasks.md](tasks.md), phases 3 and 4).

## 0. Before the transfer

1. **Check that you can create repositories in the org.** Go to
   `https://github.com/organizations/ouroboric-dev/settings/member_privileges`. As an org owner you
   always can.
2. **Check that the name is free.** `https://github.com/ouroboric-dev/picasso` should return 404.
3. **Check the Actions policy in each consumer org.** Go to
   `https://github.com/organizations/marola-dev/settings/actions`. If it says "Allow select
   actions", add `ouroboric-dev/picasso/*`. Personal-account repositories allow all actions by
   default.
4. **Check ouroboric-dev's own Actions defaults.** Go to
   `https://github.com/organizations/ouroboric-dev/settings/actions`. Actions must be allowed for
   all repositories, or for picasso. picasso's workflows need nothing more than `contents: read`,
   so a read-only default `GITHUB_TOKEN` is fine.
5. **Write down the counts** of open and closed issues, PRs and stars on `h0ffmann/picasso`, for
   SC-003.
6. **Do not turn on Zenodo yet.** If it is already on for `h0ffmann/picasso` at
   `https://zenodo.org/account/settings/github/`, turn it off.

## 1. Transfer

1. Go to `https://github.com/h0ffmann/picasso/settings` → Danger Zone → **Transfer ownership**.
2. Pick "an organization or user", type `ouroboric-dev`, keep the name `picasso`, and confirm.
3. **Check:** `https://github.com/ouroboric-dev/picasso` shows the issues, PRs and stars from 0.5.
   `https://github.com/h0ffmann/picasso` redirects there.
4. From now on, never create a repository named `picasso` or `nix-config` on `h0ffmann`, and never
   fork picasso back to it. Either one deletes the redirects.

## 2. Access

1. **Claude GitHub App:** go to `https://github.com/apps/claude/installations/select_target`, pick
   ouroboric-dev, and include `picasso`.
2. **Third-party access:** go to
   `https://github.com/organizations/ouroboric-dev/settings/oauth_application_policy` and approve
   Zenodo, plus Porkbun or Cloudflare if #85 picks them.
3. **This Claude project:** in Project settings → repositories, replace `h0ffmann/picasso` with
   `ouroboric-dev/picasso`.
4. **Secrets:** check that `PROFILE_DISPATCH_TOKEN` is still listed at
   `https://github.com/ouroboric-dev/picasso/settings/secrets/actions`. Secrets move with the
   repository. The token itself is scoped to `h0ffmann/h0ffmann` and does not change.

## 3. Local clones

On every machine with a checkout:

```console
git remote set-url origin git@github.com:ouroboric-dev/picasso.git
git remote -v        # check
```

The workstation's `~/nix-config` path and the `nix-config/` submodule directories keep their names.

## 4. Review and merge the agent PRs

The order is in [tasks.md](tasks.md):

1. picasso's own PR (phase 3). Merge it **before** step 5.
2. The consumer PRs (phase 4), in any order. For marola, file the issue and label it `agent-ready`
   first. The agent cannot start without it.
3. **Check:** CI is green on `main` in every repository. Then run
   `git grep -nE "h0ffmann/(nix-config|picasso)"` in each one, and only dated records should
   match.

## 5. Zenodo and the first release

1. Go to `https://zenodo.org/account/settings/github/`, click **Sync now**, and turn on
   `ouroboric-dev/picasso`.
2. Tag and release `v0.1.0` on GitHub (Releases → Draft a new release).
3. **Check:** the Zenodo record lists `https://github.com/ouroboric-dev/picasso`. Then ask an agent
   to add the concept DOI to `CITATION.cff` and the README.

## 6. Hosting (#85)

Set up the hosting from #85 against `ouroboric-dev/picasso`. For GitHub Pages with the custom
domain, verify the domain on the org first, at
`https://github.com/organizations/ouroboric-dev/settings/pages`. Then add the DNS records at
Porkbun, and only after that set the domain in the repository's Pages settings.

## 7. Profile

Pin `ouroboric-dev/picasso` on `https://github.com/h0ffmann`. It is no longer an owned repository,
so the languages card stops counting it. That is expected.

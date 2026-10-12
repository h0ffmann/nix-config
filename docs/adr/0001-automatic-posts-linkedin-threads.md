# 0001: Automatic posts to LinkedIn and Threads

- **Status**: Proposed
- **Date**: 2026-10-12
- **Deciders**: Hoffmann

## Context

picasso announces its work by hand. The first post, [instagram_001](../social/instagram_001/), was
written, rendered and published manually. A release (`just release`, `release.yml`) makes a GitHub
release and a Zenodo DOI, but nothing tells people about it. We want the release flow, and a post
under `docs/social/`, to publish to **LinkedIn** and **Threads** automatically.

The facts below come from the official documentation, read on 2026-10-12. Each one has its source.

### Threads (Meta)

- Publishing is two calls: `POST /{threads-user-id}/threads` makes a media container (`TEXT`,
  `IMAGE`, `VIDEO` or `CAROUSEL`), then `POST /{threads-user-id}/threads_publish` publishes it.
  Meta recommends a wait of about 30 seconds between the two calls.
  ([Posts](https://developers.facebook.com/docs/threads/posts))
- Limits: 500 characters for text, 2 to 20 items in a carousel, 250 posts for each profile in
  24 hours (a carousel is one post), at most 5 distinct links. Images and videos must be at a
  public URL when the container is made; there is no upload. ([Posts](https://developers.facebook.com/docs/threads/posts))
- Permissions: `threads_basic` and `threads_content_publish`. A Meta app with the Threads use
  case is necessary. A user who has a role on the app (a **Threads Tester**) can grant the
  permissions without App Review; other users need App Review and a published app. Because only
  Hoffmann's own profile posts, App Review is not necessary.
  ([Get started](https://developers.facebook.com/docs/threads/get-started))
- Tokens: a short-lived token lasts 1 hour. Exchange it (`grant_type=th_exchange_token`) for a
  long-lived token that lasts **60 days**. Refresh it with `GET /refresh_access_token`
  (`grant_type=th_refresh_token`) when it is at least 24 hours old and not expired; each refresh
  gives 60 more days. An expired token cannot be refreshed: then a person must log in again.
  ([Long-lived tokens](https://developers.facebook.com/docs/threads/get-started/long-lived-tokens))

### LinkedIn, personal profile

- The **Share on LinkedIn** product is self-serve: add it to the app in the Developer Portal and
  it gives `w_member_social`, which posts on behalf of the member who authorized the app.
  ([Share on LinkedIn](https://learn.microsoft.com/en-us/linkedin/consumer/integrations/self-serve/share-on-linkedin))
- The current endpoint is `POST https://api.linkedin.com/rest/posts` with the headers
  `Linkedin-Version: YYYYMM` and `X-Restli-Protocol-Version: 2.0.0`; `author` is
  `urn:li:person:{id}`. Images are uploaded first through the Images API; an organic post with
  several images uses MultiImage (organic carousels are not supported).
  ([Posts API](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api))
- Each `Linkedin-Version` is retired about one year after its release. For example, 202510 is
  retired on 2026-10-15 (notice on the same page). The pinned version must be bumped.
- Tokens: an access token lasts **60 days**. Programmatic refresh tokens (365 days) are given
  only to approved Marketing Developer Platform partners, so this app gets none: **a person
  must authorize again every 60 days**.
  ([Refresh tokens](https://learn.microsoft.com/en-us/linkedin/shared/authentication/programmatic-refresh-tokens))
- Rate limit: 150 requests for each member per day (Share on LinkedIn page).

### LinkedIn, company page

Posting to a company page **is possible through the API, but not for this project now**:

- It needs `w_organization_social`, and the member who authorizes must be an ADMINISTRATOR,
  CONTENT_ADMIN or DIRECT_SPONSORED_CONTENT_POSTER of the page.
  ([Posts API](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api))
- That permission comes only with the **Community Management API**, a vetted product. LinkedIn
  says: "our Community Management APIs are only available to registered legal organizations for
  commercial use cases only". The request needs a verified business email (personal addresses
  fail), the organization's legal name, registered address, website and privacy policy, and a
  super admin of the page must verify the app. The product must be the only product on its app,
  and a rejected app cannot apply again.
  ([App review](https://learn.microsoft.com/en-us/linkedin/marketing/community-management-app-review),
  [Overview](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/community-management-overview))
- The Development tier allows 500 calls for each app and 100 for each member in 24 hours. The
  Standard tier needs a second review with a screencast of the OAuth flow and of posting, and an
  app must apply for it within 12 months or lose access.

picasso is a personal project with no registered legal organization, so a company page (for
picasso, marola-dev or ouroboric-dev) cannot post automatically today. If one of those becomes a
legal organization, a new ADR can add it.

## Decision

1. **Targets**: Hoffmann's personal LinkedIn profile (Share on LinkedIn, `w_member_social`) and
   Hoffmann's Threads profile (Threads Tester role, no App Review). No company page.
2. **When**: on a release, `release.yml` dispatches a new `social.yml` workflow, as it already
   does for `pages.yml`. A dispatch is necessary because a release made with `GITHUB_TOKEN` does
   not start other workflows. `social.yml` also has `workflow_dispatch` with a `post` input (a
   directory under `docs/social/`) to publish a prepared post.
3. **A person approves each post**: the job runs in a GitHub environment `social` with Hoffmann
   as required reviewer. A post cannot be taken back from every feed and cache, so it waits for a
   human, like a release tag.
4. **Content**: a post is a directory under `docs/social/<id>/` with `post.json` (text for each
   network, image paths, alt texts). For a release, `social.yml` writes the text from the tag, the
   release URL and the DOI. Images go to Threads by their public URL at the tagged commit
   (`raw.githubusercontent.com/h0ffmann/picasso/<sha>/...`), and to LinkedIn through the Images
   API upload.
5. **Code**: one script, `scripts/social-post.sh` (`#!/usr/bin/env bash`, `set -euo pipefail`),
   with `--dry-run` (print the requests, send nothing) and `--self-test` (fake `curl` on `PATH`),
   as `AGENTS.md` asks of scripts. A root `justfile` recipe `social-post` calls it, with only the
   syntax that just 1.21 (Ubuntu 24.04's apt package) knows: no recipe attributes such as
   `[group]`. CI runs the self-test.
6. **Secrets** (repository or `social` environment secrets, never in a file): `THREADS_USER_ID`,
   `THREADS_ACCESS_TOKEN`, `LINKEDIN_ACCESS_TOKEN`, `LINKEDIN_AUTHOR` (`urn:li:person:...`),
   `LINKEDIN_CLIENT_ID` and `LINKEDIN_CLIENT_SECRET` (the introspection call needs them). The
   pinned `Linkedin-Version` is a value in the script, bumped by hand.
7. **Tokens**: a weekly `social-tokens.yml` refreshes the Threads token and writes it back with
   `gh secret set`, through a fine-grained PAT (`SOCIAL_SECRETS_PAT`, Secrets: write on picasso
   only). For LinkedIn it asks `POST https://www.linkedin.com/oauth/v2/introspectToken` for the
   token's `expires_at`
   ([Token introspection](https://learn.microsoft.com/en-us/linkedin/shared/authentication/token-introspection)), and opens an issue
   for Hoffmann when fewer than 14 days are left. `just social-auth linkedin` runs the OAuth flow
   on the workstation and sets the new secret.

## Alternatives

- **A third-party scheduler (Buffer, Hootsuite, Zapier, Make)**: it hides the token problem, but
  adds an account, a paid plan for more than a few channels, and a dependency outside the repo.
  Rejected; it can come back if the 60-day LinkedIn renewal is too much work.
- **Post without a human gate**: faster, but a wrong post goes out with no review. Rejected.
- **Company page through a partner tool**: tools that are approved Community Management partners
  can post to pages. That puts the page behind an outside service. Not now.
- **Only Threads** (no LinkedIn renewal): it loses the network where the audience for picasso is.

## Consequences

- Every 60 days Hoffmann authorizes LinkedIn again (one command). If that is not done, the LinkedIn
  step fails and the issue from `social-tokens.yml` says why. The Threads token stays valid while
  the weekly refresh runs; if it fails for more than 60 days, a new login is necessary.
- `SOCIAL_SECRETS_PAT` has its own expiry; the same workflow warns before it.
- About once a year, the pinned `Linkedin-Version` must move before LinkedIn retires it.
- Threads images must be in the repo at the tagged commit; a post with an image that is not
  committed fails at container creation.
- Instagram (Meta Graph API, Business or Creator account) is out of scope. It can reuse the Meta
  app in a later ADR.
- Implementation is a separate PR after this ADR is Accepted.

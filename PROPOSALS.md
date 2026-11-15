# Proposals: website

Written by loopers. Each proposal: what, why, links. Jody promotes accepted ones into ROADMAP.md (via an agent);
the looper then marks it `promoted` or `declined` here with the date.

## Open
- **Planning-files check in `just gates`** (2026-10-28, tacplus-dev/website#1): once tacplus-dev/looper ships a
  `just`-callable form of the check, add it to the `gates` recipe and retire `.github/workflows/planning-files.yml`, as
  tacplus-dev/roadmap decisions/ci-on-gitlab-2026-10-27.md makes it a gate. Issue #1 left it out of scope.
- **Decide the site's path past MkDocs 1.x** (2026-11-13, nightly scan): every `just gates` prints Material for
  MkDocs' warning that MkDocs 2.0 drops the plugin and theming systems with no migration path
  (https://squidfunk.github.io/mkdocs-material/blog/2026/02/18/mkdocs-2.0/). Nothing breaks today:
  mkdocs-material 9.7.7 requires `mkdocs<2,>=1.6` and requirements.txt pins mkdocs 1.6.1. But the site's whole
  toolchain sits on a 1.x line that upstream is leaving, so a security fix there may never come. Choose, before that
  happens, whether to stay pinned on 1.x, follow Material's own successor, or move generators.
- **`build.lock` follows the 2.6 line's latest patch by itself** (2026-11-15, nightly scan; tacplus-dev/website#3):
  the pin was set once at v2.6.1 and sat there through the DSA-6628-1 rebuild (tacplus-dev/tacplus#711, v2.6.12,
  2026-11-14), so the pinned image carried six fixable HIGH kernel CVEs for a day before a scan noticed. The fleets
  already pin by release line (MAJOR.MINOR → latest patch, image by digest; platform ROADMAP.md Next 3), but a
  `build.lock` of a non-tacplus repository is moved by hand. Proposal: when `build:2.6`'s digest on ghcr moves off the
  pinned one, the looper (nightly scan or a build-pin job) opens the `approved` move itself, or a `just`-callable check
  in the gates reports the lag. Belongs with the platform's "Automatic security remediation" (ROADMAP.md Later) and
  tacplus-dev/looper, not here; recorded so the pattern is not lost.

## Promoted / declined

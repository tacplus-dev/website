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
  tacplus-dev/looper, not here; recorded so the pattern is not lost. It recurred at once: v2.6.13 shipped 40 minutes
  after the move to 2.6.12, and the next nightly scan found the pin behind again (2026-11-16, tacplus-dev/website#4).
- **Pin the site's toolchain by hash and the workflows' actions by commit** (2026-11-15, nightly scan):
  requirements.txt pins every package by version only, so `pip install -r requirements.txt` (the `venv` recipe,
  `.github/workflows/site.yml`) trusts PyPI to serve the same wheel each time; pip-audit's own warning each run is
  "users are encouraged to fully hash their pinned dependencies". `pip-compile --generate-hashes` (or
  `pip freeze` plus `pip hash`) gives a requirements.txt pip verifies with `--require-hashes`, and site.yml's
  `actions/checkout@v4`, `setup-python@v5`, `upload-pages-artifact@v4`, `deploy-pages@v4` and
  `planning-files.yml`'s `tacplus-dev/looper/...@main` would become `@<sha>  # vN` pins the same way the fleets pin
  images by digest (build.lock). Small, mechanical, but a policy for the fleet's non-tacplus repositories, so for
  Jody to set rather than one repository to adopt alone. The build pipeline's security checks (tacplus-dev/website#2,
  first run 2026-11-15) report the four action tags as Semgrep `github-actions-mutable-action-tag`, MEDIUM, each with
  a fix: not failing the policy (HIGH/CRITICAL), so the build is green, and they are not baselined
  (no `security-baseline.json`) so they stay visible in every report until this is decided.

## Promoted / declined

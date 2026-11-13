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

## Promoted / declined

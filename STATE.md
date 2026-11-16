# State: website

Overwritten to stay current (loopers and agents). Last updated: 2026-11-16 by looper (issue #4).

- **Version / line:** no release yet (no tags); no tacplus floor (the site uses MkDocs, not the compiler)
- **Works:** the tacplus.dev site builds strictly (`just site`); `just gates` runs that strict build for the build pipeline,
  in the image `build.lock` pins by digest (tacplus build 2.6.13). The build pipeline (tacplus-dev/build) plans a build
  of `main` from that pin and sets its verdict as the commit status `tacplus-dev/build`: the gates and the security
  checks pass (first on 2026-11-15, issue #2); a nightly of `main` is scheduled there too (tacplus-dev/cloud#31)
- **Released / deployed:** `main` deploys to GitHub Pages (`.github/workflows/site.yml`), https://tacplus.dev
- **Known gaps:** the planning-files check is not yet part of `just gates` (it runs as a GitHub workflow); the security
  checks report four MEDIUM Semgrep findings, the mutable action tags in `site.yml`, which fail nothing and wait on a
  fleet policy; see PROPOSALS.md
- **Blocked on:** nothing

# State: website

Overwritten to stay current (loopers and agents). Last updated: 2026-11-08 by looper (issue #2).

- **Version / line:** no release yet (no tags); no tacplus floor (the site uses MkDocs, not the compiler)
- **Works:** the tacplus.dev site builds strictly (`just site`); `just gates` runs that strict build for the build pipeline,
  in the image `build.lock` pins by digest (tacplus build 2.6.1)
- **Released / deployed:** `main` deploys to GitHub Pages (`.github/workflows/site.yml`), https://tacplus.dev
- **Known gaps:** the planning-files check is not yet part of `just gates` (it runs as a GitHub workflow); see PROPOSALS.md
- **Blocked on:** nothing

# tacplus.dev

The website for tacplus, the open-source fleet: https://tacplus.dev

The site explains the whole; each repository's README holds its own detail.
MkDocs + Material. Build with `just site`, preview with `just serve`. Pushes to
`main` deploy to GitHub Pages (`.github/workflows/site.yml`).

The build pipeline (tacplus-dev/build) runs `just gates` in the image `build.lock` pins by digest; to move it, change
that digest in a commit of its own, landed on the full gates like any other change.

Copyright (c) 2026 Jody Scott. Apache License 2.0.

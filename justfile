# tacplus.dev. `just site` builds into build/, `just serve` previews at
# http://127.0.0.1:8000 with live reload.

site: venv
  .venv/bin/mkdocs build --strict

# The repository's gates, as the build pipeline runs them: a strict site build.
gates: site

serve: venv
  .venv/bin/mkdocs serve --strict

venv:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ ! -x .venv/bin/mkdocs || requirements.txt -nt .venv/.installed ]]; then
    python3 -m venv .venv
    .venv/bin/pip install --quiet -r requirements.txt
    touch .venv/.installed
  fi

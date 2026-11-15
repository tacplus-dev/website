# History: website

Append-only: add entries at the end, never edit or remove one (CI enforces it). One line each:
`- <YYYY-MM-DD> <who: looper|agent|jody> <kind: issue|decision|release|deploy> <one line> (<links>)`

- 2026-10-28 looper issue justfile: no `gates` recipe, so `just gates` fails on main (#1, a3cffbb)
- 2026-11-15 looper issue build.lock pins tacplus build 2.6.1: the 2.6 line is at 2.6.12 (DSA-6628-1 rebuild), so the pinned image fails the security scan and no longer matches the digest its header follows (#3, ee3220f)

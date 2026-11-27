# History: website

Append-only: add entries at the end, never edit or remove one (CI enforces it). One line each:
`- <YYYY-MM-DD> <who: looper|agent|jody> <kind: issue|decision|release|deploy> <one line> (<links>)`

- 2026-10-28 looper issue justfile: no `gates` recipe, so `just gates` fails on main (#1, a3cffbb)
- 2026-11-15 looper issue build.lock pins tacplus build 2.6.1: the 2.6 line is at 2.6.12 (DSA-6628-1 rebuild), so the pinned image fails the security scan and no longer matches the digest its header follows (#3, ee3220f)
- 2026-11-15 looper issue Pin the build: a committed build.lock naming this repository's build image by digest (#2)
- 2026-11-16 looper issue build.lock pins tacplus build 2.6.12: build:2.6 now resolves to v2.6.13, so the pin no longer follows the line's latest patch as its header says (#4)
- 2026-11-20 looper issue Site is dated: kmaker (archived) still listed, letsencrypt drawn as a fleet service; say config and cert come from the pipeline (#5)
- 2026-11-23 looper issue Pinned images behind their lines: relock (build.lock: ghcr.io/tacplus-dev/tacplus/build:2.6.13 → ghcr.io/tacplus-dev/tacplus/build:2.6.14) (#7)
- 2026-11-27 looper issue Pinned images behind their lines: relock (build.lock: ghcr.io/tacplus-dev/tacplus/build:20261123-57a6521 → ghcr.io/tacplus-dev/tacplus/build:20261126-57a6521) (#9)

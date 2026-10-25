---
description: How tacplus is versioned, how fixes and features are taken in, how to report a security issue, who owns it and under what license.
---

# Project

## Versions and the pin rule

Every tacplus repository releases as `MAJOR.MINOR.PATCH` git tags.

- **A patch is fixes only.** It changes behaviour only where the previous
  behaviour was a defect. Nothing a consumer would have to learn about goes
  into a patch.
- **Features come in on a minor.** A new annotation, a new generated surface,
  a new rpc: `MAJOR.MINOR+1.0`.
- **A major is a breaking change** to what consumers already build against.
  Generated code is regenerated; there is no deprecation window.

Consumers pin **major and minor**, never a patch. `2.3` means "the newest
2.3.x", and every 2.3.x is safe to take without reading the notes, because a
patch is fixes only. Images carry `X.Y.Z`, `X.Y` and `X` tags; pin `X.Y`.
Pinning a patch is for reproducing a problem, never for staying on a known
defect.

Every fix is made on `main` first and backported to every minor released in the
last twelve months, as a patch of that minor on its `release/MAJOR.MINOR`
branch. The compiler's
[versioning policy](https://github.com/tacplus-dev/tacplus/blob/main/docs/VERSIONING.md)
is the full text.

## Fixes and features

Fixes come in through GitHub issues on the repository concerned, using its
fix-request template. A nightly job takes the oldest open request, fixes it on
`main`, backports it to every supported minor, and opens the pull requests.

Features come in as feature requests. Each gets a written review on the
issue: is it a gap, should this project do it, what it costs, the
alternatives, and a recommendation. The maintainer decides. An approved feature
is built for the next minor, in every full-service language at once.

## Security

Do not open a public issue for a security problem. Email
**jody@seabeam.net** with the affected repository, version or commit, and
steps to reproduce. You will get an acknowledgement within three business
days and a fix or a mitigation plan as soon as there is one. Each repository's
`SECURITY.md` says what is in scope for it; for the compiler, that is anything
that makes the generated code unsafe and anything in the compiler a crafted
proto could exploit.

A nightly security sweep runs over every supported release line: secrets,
dependencies and the published images.

## License and ownership

Every repository under [github.com/tacplus-dev](https://github.com/tacplus-dev)
is open source under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
and copyright Jody Scott. The rule is simple: if it is on GitHub under
tacplus-dev, it is open source and part of tacplus. Services built on tacplus
by other people, open or closed, are theirs.

## Contributing

Each repository has a `CONTRIBUTING.md` and a code of conduct. The short
version: open an issue first, keep a change to one thing, and expect the
gates to run on your pull request.

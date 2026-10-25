---
description: Write a tacplus service, annotated protobuf in, a complete validated and authorized service out, in Go, Rust or Java.
---

# Build a service

A tacplus service is a proto file with `spec` annotations and a handler. The
compiler generates everything between the two: validation from the `assert_*`
annotations, the server wrapper that authenticates and authorizes every call,
the caller identity, state ownership, lifecycle, health, and the clients other
services and users call it with. Every user-facing rpc is also an MCP tool with
the same authorization as the rpc.

The compiler is the [tacplus repository](https://github.com/tacplus-dev/tacplus).
Its documentation is the reference; this page is the map.

## Install the compiler

tacplus is a single binary that drives `protoc` and the plugins for the
languages you generate. Take a release binary from
[GitHub Releases](https://github.com/tacplus-dev/tacplus/releases), check it
against `checksums.txt`, and put it on your `PATH`. Keep it current with:

```bash
tacplus upgrade
```

Or run the image, which carries `protoc` and every plugin:

```bash
docker run --rm -v "$PWD:/work" -w /work ghcr.io/tacplus-dev/tacplus/tacplus:2.3 build --config tacplus.yaml --src ./proto
```

Pin the image to a `MAJOR.MINOR` tag, never a patch: a patch is fixes only, and
the floating minor tag always points at the newest one. The compiler repository's
[install guide](https://github.com/tacplus-dev/tacplus/blob/main/docs/USER.md)
has the per-platform steps and what `tacplus build` needs on the host.

## The quick start

The compiler repository's `example/` is one small tenant-scoped notes service,
generated twice from one proto set, a Go server and a TypeScript client. One
command builds the compiler, generates both, starts the server and drives it
with the client:

```bash
git clone https://github.com/tacplus-dev/tacplus
cd tacplus
just example
```

The run ends with the generated client refusing an invalid request before it
reaches the wire, with the same message the server would give, because both
sides come from the same annotation. The
[README](https://github.com/tacplus-dev/tacplus#readme) walks through the proto
line by line.

## Write the contract

Everything the compiler needs to know is in the proto:

- `option (spec.service)` names the service. Its id comes from the
  [registry](https://github.com/tacplus-dev/registry), never by hand.
- `assert_required`, `assert_min_size`, `assert_max_size` and the other
  `assert_*` field options become validation in the server wrapper and in
  every client.
- `service_c2s` makes an API callable by authenticated users through the
  gateway; `service_s2s` makes it callable by other services. A declared
  dependency produces the client for it, and nothing is switched on in YAML.
- `spec.rpc` sets each rpc's principal, exposure and auth flags, and
  `target_namespace_field` names the field that scopes it to a tenant.
- `spec.service_store` gives the service typed, owned state with generated
  disk persistence.

A `tacplus.yaml` says which language and package to generate, the `MAJOR.MINOR`
of tacplus the project is built against, and nothing about the service itself.

## Pick a language

| Tier | Languages | What you get |
|---|---|---|
| **Full service** | Go, Rust, Java | Every surface, server and client. The three are kept at parity in capability; a gap is a defect. |
| **Full client** | TypeScript, Python | Every client surface with client-side validation. No server runtime, by design. |
| **Lite client** | Swift, C# | Client-to-service, web-to-service and client-to-daemon clients. |

The surface-by-surface matrix, the user guide and the generated API are in the
compiler repository:

- [User guide](https://github.com/tacplus-dev/tacplus/blob/main/docs/USER.md):
  the build, the registry, fleet build, the CLI
- [Generated API](https://github.com/tacplus-dev/tacplus/blob/main/docs/API.md):
  what the generated code looks like per language and surface
- [Theory](https://github.com/tacplus-dev/tacplus/blob/main/docs/THEORY.md):
  why the contract lives in the proto
- [Annotation reference](https://github.com/tacplus-dev/tacplus/blob/main/pkg/proto/sys/spec.proto):
  every `spec` option, in the proto that defines them

## Put it in a fleet

A service that compiles is not yet in a fleet. It needs an id from the
registry, an image, and an entry in a fleet manifest. [Run a fleet](run.md)
shows the manifest; [Replace a piece](replace.md) explains what the manifest
decides and what the registry does not.

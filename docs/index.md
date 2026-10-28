---
title: The open-source fleet
description: tacplus is an open-source fleet. Describe services in annotated Protocol Buffers, generate them in Go, Rust or Java, and run them as a tenant-isolated fleet on Kubernetes.
hide:
  - navigation
  - toc
---

<div class="tp-hero" markdown>

# tacplus

<p class="tp-tagline">An open-source fleet, built for the way software is written now: AI writes the handler, never the server.</p>

tacplus is everything it takes to stand up and run a fleet of services on
Kubernetes. You describe each service in annotated Protocol Buffers. The
compiler generates everything around the business logic, in Go, Rust or Java:
authentication, authorization, validation, identity, state, retries, clients,
and an MCP tool for every rpc. The platform runs the result as a fleet: one
token authority, one edge, one event bus, one record store, one policy engine,
one door to the model vendor, tenant isolation checked at the door. Every
repository under [github.com/tacplus-dev](https://github.com/tacplus-dev) is
part of it, and all of it is Apache-2.0.

[Run a fleet](run.md){ .md-button .md-button--primary }
[Build a service](build.md){ .md-button }
[What it does](features.md){ .md-button }
[Why tacplus](why.md){ .md-button }
[GitHub](https://github.com/tacplus-dev){ .md-button }

</div>

## Built for agents

**AI writes the handler. It never writes the server.** Authentication,
authorization, validation, identity, retries, readiness, health, state access
and clients are generated from the proto, the same for every service, in every
language, every time. A model writes business logic inside a typed handler
interface and nothing else. A new model, a new session or a new agent cannot
produce its own slightly different server, its own idea of auth, or its own
retry loop, because that code is generated, versioned, gated and tested as one
thing. AI helps build the generator too, through issues, reviews and gates,
under control.

**Every user-facing rpc is an MCP tool, automatically, with the same
authorization as the rpc.** The tool schema comes from the request message.
Fields the server computes, such as the caller's identity or tenant, are absent
from the schema rather than ignored; a model cannot fill them in.

**One door to the model vendor, and the model never holds a credential.**
llmproxy is the only service that can reach a model. It authenticates to the
vendor with a federated identity, never a static key, and every other service
calls it under its own identity with a budget per caller. When a model turn
uses a tool, the call comes back down the calling service's own stream and runs
as that service, under its own token and its own authorization.

**Identity is checked at the door, by generated code.** One token authority.
Services bootstrap from the identity Kubernetes already gave them. SPIFFE
identities with a fixed layout. A tenant-owned service runs once per tenant,
and a caller from another tenant is refused before any handler runs.

**Sandboxed workers with a child identity.** A service can ask for a
short-lived sandboxed worker. The kernel mints it an identity as a child of the
requesting service, so it can only ever be what its parent is, less.

**The project is maintained by agents under gates.** Fixes come in as issues
and a nightly agent fixes, backports and opens the pull requests; nothing
merges without the gates. Feature requests get a written review and a human
decides. A nightly security sweep covers every release line.

[The full list, grouped](features.md){ .md-button .md-button--primary }

## What you get

<div class="grid cards tp-two" markdown>

-   :material-code-braces:{ .lg .middle } **A compiler**

    ---

    `tacplus build` turns a proto set with `spec` annotations into a complete
    service: the handler interface is yours, everything around it is
    generated, in every full-service language at parity.

    [:octicons-arrow-right-24: Build a service](build.md)

-   :material-server-network:{ .lg .middle } **A platform**

    ---

    Kernel, gateway, eventbus, stratum, opa, oauth, letsencrypt, kmaker, the
    operator library and llmproxy: the services every fleet needs, each in its
    own repository with its own README.

    [:octicons-arrow-right-24: The pieces](pieces.md)

-   :material-ship-wheel:{ .lg .middle } **A way to run it**

    ---

    A deployment repository holds one `fleet.yaml`. `tacplus fleet build`
    resolves every service, merges the protos, checks the whole fleet and
    writes the lock. The operator renders the cluster from that.

    [:octicons-arrow-right-24: Run a fleet](run.md)

-   :material-swap-horizontal:{ .lg .middle } **A way to replace any of it**

    ---

    The registry decides a service's name and id. The fleet manifest decides
    which implementation runs. A fleet may run its own kernel, open or closed,
    under the same name and number.

    [:octicons-arrow-right-24: Replace a piece](replace.md)

</div>

## The shape of it

```mermaid
flowchart LR
  user([user or client]) --> gw[gateway]
  gw --> svc[your services]
  gw --> oauth[oauth]
  oauth --> kernel
  svc --> kernel[kernel<br/>state host, token authority]
  kernel --> opa[opa]
  svc --> bus[eventbus]
  bus --> stratum[stratum<br/>record store]
  svc --> llm[llmproxy]
  kmaker[kmaker] -. signs .-> kernel
  le[letsencrypt] -. cert .-> gw
```

Every arrow is a generated client calling a generated server, authenticated
with a token kernel minted and authorized by the annotations in the proto.
[How a fleet works](how.md) follows a call through it.

## Where the detail lives

This site explains the whole. Each repository's README holds its own detail,
and the compiler repository's `docs/` is the reference for the generated code.
The rule for what is here is simple: if it is on GitHub under tacplus-dev, it
is open source and part of tacplus.

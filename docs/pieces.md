---
description: Every repository that makes up tacplus, grouped by role, with what it is, its language, what it depends on and a link to its README.
---

# The pieces

Every repository under [github.com/tacplus-dev](https://github.com/tacplus-dev)
is part of tacplus. Each one's README is the authority on it; this page says
what each is for and how they fit. Ids are from the
[registry](https://github.com/tacplus-dev/registry).

## Compiler and registry

| Repository | Language | What it is |
|---|---|---|
| [tacplus](https://github.com/tacplus-dev/tacplus) | Go | The compiler. `tacplus build` generates a service from annotated protos; `tacplus registry` syncs a repo's id lock; `tacplus fleet build` resolves a fleet. Also defines the system contract every fleet provides: the minter and the service-health protos. |
| [registry](https://github.com/tacplus-dev/registry) | none | The append-only global allocator of service and vservice ids. Each entry names the service, its id, and the repository that holds its proto. It decides ids, not who may read what and never which implementation runs. |

## Control plane

| Repository | Language | Id | What it is | Depends on |
|---|---|---|---|---|
| [kernel](https://github.com/tacplus-dev/kernel) | Java | 8 | The fleet's state host and sole token and certificate authority. Hosts every `kernel`-labelled state root and every service's configuration. Mints every token: service, user, client, workload, external. Shared; one per fleet. | opa, kmaker |
| [kmaker](https://github.com/tacplus-dev/kmaker) | Go | 49 | The bootstrap CA. Verifies a kernel pod's Kubernetes service-account token and signs its certificate under the cluster signing CA. Starts before the kernel, on purpose. | none |
| [opa](https://github.com/tacplus-dev/opa) | Go | 29 | The policy evaluator. The kernel calls it to turn identity-provider claims into token entitlements and to evaluate proxy policy. Only the kernel talks to it directly. | none |
| [operator](https://github.com/tacplus-dev/operator) | Go | 47 | A library a deployment repository builds its own operator from. Renders Helm charts for every service from `operator.yaml` and `crypto.yaml`, provisions the PKI, and renders per-tenant instances of tenant-owned services. | kernel, oauth, kmaker, gateway, eventbus, opa, letsencrypt, llmproxy |

## Data plane

| Repository | Language | Id | What it is | Depends on |
|---|---|---|---|---|
| [eventbus](https://github.com/tacplus-dev/eventbus) | Java | 18 | Embedded Kafka in KRaft mode. Every record and event topic in the fleet is published and subscribed through generated, authenticated calls. Stamps the publisher's identity on every message. Takes no client connections. | kernel |
| [stratum](https://github.com/tacplus-dev/stratum) | Java | 34 | The durable record store. Subscribes to every record topic, so publishing a record is writing it. Serves the generated read-only query plane. Three durability legs: replication, writers' volumes, the event log. | eventbus |
| [blobstore](https://github.com/tacplus-dev/blobstore) | Go | 58 | Content-addressed blob store mirrored across two pods. Bytes over gateway-proxied HTTP, metadata as stratum records, quota per tenant. | eventbus, stratum |

## Edge

| Repository | Language | Id | What it is | Depends on |
|---|---|---|---|---|
| [gateway](https://github.com/tacplus-dev/gateway) | Rust | 7 | The edge. Terminates TLS, proxies REST and gRPC, validates every message, checks every token, routes to healthy instances from the kernel's health state, and routes tenant-owned services by the caller's tenant. Also serves the web app. | kernel (state), letsencrypt, blobstore |
| [oauth](https://github.com/tacplus-dev/oauth) | Rust | 21 | The login broker. Verifies identity-provider tokens and asks the kernel to mint the user's token; brokers CLI and device logins. Holds no signing keys. | kernel |
| [letsencrypt](https://github.com/tacplus-dev/letsencrypt) | Go | 9 | Obtains and renews the fleet's public certificate over ACME inside the cluster. The durable copy is a stratum record, the live copy is kernel state the gateway watches. | kernel, eventbus, stratum |

## Model egress

| Repository | Language | Id | What it is | Depends on |
|---|---|---|---|---|
| [llmproxy](https://github.com/tacplus-dev/llmproxy) | Rust | 75 | The one service that holds a model-vendor identity. Every other service gets completions from it over service-to-service calls. Federated identity to the vendor, never a static key. Per-caller budgets, model aliases, tool callbacks. The fleet build stamps its allowed callers. | none |

## Workloads and messaging

| Repository | Language | Id | What it is | Depends on |
|---|---|---|---|---|
| [coop](https://github.com/tacplus-dev/coop) | Go | 106 | The fleet's one door to pigeons: short-lived sandboxed workers a tenant's service asks for. Creates the run, mints its identity as a child workload of the caller, relays its thread over the bus, records the run in stratum. | kernel, eventbus, stratum |
| [pigeon](https://github.com/tacplus-dev/pigeon) | Go | 107 | The generic pigeon host image: one Kubernetes Job per run, speaking only on its thread. A product's own pigeon kind is its own host built on the same protocol. | coop, eventbus |
| [messaging](https://github.com/tacplus-dev/messaging) | Rust | 53 | The message primitive. One user-facing send that fans out one record per recipient onto the bus. | eventbus, stratum |
| [mailbox](https://github.com/tacplus-dev/mailbox) | Rust | 55 | Pull delivery over messaging: which deliveries a recipient has not yet retrieved, kept as stratum records. Optional Gmail connector. | eventbus, stratum, messaging |
| [launcher](https://github.com/tacplus-dev/launcher) | Go | | The process supervisor that is the entrypoint of every distroless Java service image. Forwards signals, propagates exit codes, kills a deadlocked JVM on failed gRPC health. | none |

## Proof and examples

| Repository | Language | Id | What it is |
|---|---|---|---|
| [tenantecho](https://github.com/tacplus-dev/tenantecho) | Go | 103 | The smallest tenant-owned service. Its reply names the tenant that served it and the tenant that called, so a routing mistake is visible in the response. |
| [doppelganger](https://github.com/tacplus-dev/doppelganger) | Go | 101 | A tenant-owned service that answers questions from stored context through llmproxy. The first real service built on the fleet, and the one the proof fleet runs. |
| [fleet-seatrials](https://github.com/tacplus-dev/fleet-seatrials) | none | 104 | The disposable proof fleet on GKE. Create the cluster, build the images from the lock, apply, log in, create two tenants, watch tenantecho answer for each, destroy. The walk-through in [Run a fleet](run.md). |
| [fleet-dev](https://github.com/tacplus-dev/fleet-dev) | none | | The dev fleet's manifest with the fuller service set, including blobstore, messaging and mailbox. |

## Where things stand

The platform services were copied out of a private tree on 2026-10-23 and are
being reworked in the open; the private copy keeps running its own fleet and
the two are not kept in sync. Expect module paths, headers and some READMEs to
still be catching up. Each README's provenance section says what changed and
what is next. Open issues and the review of every feature request are on each
repository's issue tracker.

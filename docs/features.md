---
description: What tacplus does that is worth your attention, most interesting first. Built for agents, identity checked at the door, the contract in the proto, state with one owner, a fleet you can replace any piece of.
---

# What it does

The short list, most interesting first, grouped where things belong together.
Each item is generated or enforced by the platform, not left to a convention.
Where an item lives in one repository, it is linked.

## Built for agents

**AI writes the handler. It never writes the server.** Authentication,
authorization, validation, identity, retries, reconnect backoff, readiness
gating, health, state access, clients: all of it is generated from the proto
by the compiler, and the generated code is the same for every service, in
every language, every time. A model writes the business logic inside a typed
handler interface and nothing else. That is the point: a new model, a new
session or a new agent cannot produce its own slightly different server, its
own idea of auth, or its own retry loop. The platform code is generated,
versioned, gated and tested as one thing, and the gates run on every change.
AI is used to build the generator too, but through issues, reviews and gates,
under control, never ad hoc.

**Every user-facing rpc is an MCP tool, automatically, with the same
authorization.** A service declares its rpcs once. The compiler publishes
each one as a tool with a schema derived from the request message, and
generates the session carrier that an MCP client speaks to. The carrier is an
ordinary rpc with an ordinary auth model, so a tool call is authorized exactly
as the rpc is. Fields the server computes, such as the caller's principal or
tenant, are absent from the tool schema rather than merely ignored; a model
cannot fill them in.

**One model-egress service, and the model never holds a credential.**
[llmproxy](https://github.com/tacplus-dev/llmproxy) is the only service in a
fleet that can reach a model vendor. It authenticates to the vendor with a
federated identity, never a static key. Every other service calls it over an
authenticated service-to-service rpc, under its own identity, with a budget
per caller and an allowed-caller list the fleet build stamps from what the
fleet actually contains.

**Tool calls come back down the caller's own stream, and run as the caller.**
When llmproxy drives a model turn with tools, each tool use is sent back as an
MCP frame on a callback stream the calling service opened. The calling service
executes it through its own generated MCP surface, as itself, under its own
token and its own authorization. The identity of a tool call is the
authenticated owner of the stream, never anything inside a frame. llmproxy
stores no transcript; the only live state is one stream per caller identity.

**Sandboxed workers with a child identity.** The
[coop](https://github.com/tacplus-dev/coop) is the fleet's one door to
pigeons: short-lived sandboxed workloads a service asks for, run as a
Kubernetes Job each. The kernel mints the worker an identity as a child of the
requesting service, so a worker can only ever be what its parent is, less.
Its thread with the parent runs over the bus and the run is recorded.

**The project is maintained by agents under gates.** Fixes come in as issues.
A nightly job hands the oldest to an agent, which fixes it on main, backports
to every supported minor and opens the pull requests; nothing merges without
the gates. Feature requests get a written review on the issue, with cost,
alternatives and a recommendation, and a human decides. A nightly security
sweep covers secrets, dependencies and the published images on every release
line.

## Identity and authorization

**One token authority.** The [kernel](https://github.com/tacplus-dev/kernel)
signs every service and user token and issues ordinary service certificates.
Nothing else in the fleet holds a signing key. The login broker verifies the
identity provider and asks the kernel to mint; it has no keys of its own.

**Services bootstrap from the identity Kubernetes already gave them.** A
service presents its projected service-account token to the kernel, which
verifies it with the Kubernetes TokenReview API, maps namespace and account to
a registered delegate, and mints its tokens. The generated ServiceManager does
this, refreshes, and exchanges for audience-scoped tokens per target. The
kernel itself bootstraps the same way from
[kmaker](https://github.com/tacplus-dev/kmaker), a small CA that runs before
it.

**SPIFFE identities with a fixed layout.** Shared services under `/system`,
tenant instances and tenant users under `/tenants/<tenant>`, users that exist
outside every tenant under `/users/<xid>`, spawned workloads under their parent.
The identity is derived from the token's claims by generated code; it is never
carried as a string a caller could set.

**Tenant isolation at the door.** A tenant-owned service runs once per tenant.
The gateway routes a call to the caller's tenant's instance by reading the
tenant from the token, and the instance's generated wrapper refuses a caller
from another tenant before the handler runs. Which rpcs are scoped to a
tenant, and by which field, is declared in the proto.

**Delegation with an actor claim.** A service may act on another principal's
behalf only through a grant the kernel holds. The minted token names the
subject and the delegate separately, and an rpc declares which delegates may
call it that way. The kernel re-evaluates policy at every delegated mint.

**Entitlements are generated, not strings.** User tokens carry a grants list
whose values are generated from the rpcs that exist. Wildcards expand through
generated helpers to exact rpc grants. There is no `"*"` string to get wrong,
and a grant for an rpc that does not exist cannot be written.

**Data entitlement at egress.** A record field can be marked redactable or
anonymizable on its way out, by a lattice that can only tighten at runtime.
What a principal may see of another principal's rows is decided per field in
the proto, enforced by generated readers.

**Formal invariants.** A field can carry an invariant, and `tacplus verify`
proves it: a kani harness in Rust, a JBMC harness in Java.

## The contract lives in the proto

**Validation on both sides, from one annotation.** A size, range, required or
enum constraint in the proto becomes validation in the server wrapper and in
every generated client. The client refuses the invalid request before it
reaches the wire, with the same message the server would give.

**Three full-service languages at parity.** Go, Rust and Java each get every
surface: server wrapper, handler interface, state, persistence, clients, MCP.
Capability parity is enforced as a rule; a gap is a defect. TypeScript,
Python, Swift and C# get the client surfaces.

**Collections with a contract.** An rpc that returns many things declares its
mode: a page, a bounded snapshot, or a watch, each with a specified flow
control and teardown. A watch is a watch everywhere, with the same semantics
in every language.

**A closed verb registry.** Rpc names come from a fixed list of verbs with
defined meanings, so a reader and a generator both know what `Watch`,
`Broker`, `Subscribe` or `Mint` implies. A name outside it fails generation.

**REST and the gateway routes come out of the same compile.** The gateway's
routing table, the REST-to-gRPC dispatch, server-sent events and web sockets
are generated from the proto, so there is no second description of the API
for the edge to drift from.

**The system contract is a proto too.** The minter every ServiceManager calls
and the service-health plane the gateway routes from are declared in the
compiler's own `sys/` protos; a fleet provides them like any other service.

## State with one owner

**Live state in the kernel, watched not polled.** A state root labelled
`kernel` is hosted in the kernel's in-memory cluster behind generated get, set
and watch services. Configuration, health, policy and the live certificate
all move this way.

**Records are event-sourced.** A record type gets a topic on the
[eventbus](https://github.com/tacplus-dev/eventbus). Publishing the record is
writing it;
[stratum](https://github.com/tacplus-dev/stratum) subscribes to every record
topic and stores what arrives. The read plane is read-only and a service may
read only the rows it declared it may read. The publisher's identity is
stamped on every message by the bus from the token, never by the publisher.

**Typed disk persistence.** A service's owned store gets a generated redo log
with periodic compaction, typed readers and a roll scheduler, so persistence
reads and writes proto types with generated serialization, never ad hoc file
I/O. A quorum write gate makes a write wait for durable copies.

**Bytes have their own home.** The
[blobstore](https://github.com/tacplus-dev/blobstore) is content-addressed and
mirrored, with metadata as records and quota per tenant.

## A fleet you can run and replace

**A fleet is one file.** A deployment repository holds `fleet.yaml`: the
registries it trusts, the compiler version, and the repository that
implements each service. `tacplus fleet build` resolves it, checks every
dependency is present, merges the protos, stamps the caller lists, runs the
whole-fleet checks and writes the lock with the exact commit of everything.

**Ids are permanent and come from a registry.** The
[registry](https://github.com/tacplus-dev/registry) allocates each service's
id once, append-only, never reused. It decides ids, not who may read what,
and never which implementation runs.

**Any piece can be replaced.** The manifest, not the registry, decides which
implementation of a service a fleet runs. A fleet may run its own kernel, open
or closed, under the same name and id, and everything generated against the
contract keeps working. [Replace a piece](replace.md) has the details.

**The operator is a library.** A deployment repository builds its own operator
from it, against its own merged protos, so the operator knows exactly the
services its fleet runs. It renders a per-tenant instance of every
tenant-owned service from the kernel's tenant records.

**Public certificates from inside the cluster.**
[letsencrypt](https://github.com/tacplus-dev/letsencrypt) runs the ACME
exchange in-cluster and keeps the one durable copy as a record, so a fleet is
a real OIDC issuer outside systems can trust.

**Versioning you can pin without reading the notes.** A patch is fixes only.
Features come on a minor. Consumers pin `MAJOR.MINOR`, images carry the
floating minor tag, and every fix is backported to every minor under a year
old.

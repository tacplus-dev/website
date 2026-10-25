---
description: The thesis behind tacplus. The contract lives in the proto, identity is checked at the door, state has one owner, three languages stay at parity, and any piece can be replaced.
---

# Why tacplus

Every service in a multi-language platform needs the same things: typed
messages, validated inputs, authentication, authorization, state it owns,
health, clients for everyone who calls it. The usual answer is a shared
library per language plus conventions. The contract ends up scattered: a rule
changes in Go and not in Java, a service writes state it does not own, an auth
check exists on one path and not another.

tacplus takes a different position on five things.

## The contract lives in the proto

The proto file is where every language already agrees on the shape of the
data. tacplus puts the rest of the contract there too: which fields are
required and how large they may be, who may call which rpc, which tenant a
call is scoped to, which state a service owns, which other services it
depends on. The compiler generates everything that follows. A rule exists once
and is enforced the same way in the server wrapper and in every client, so the
client refuses the invalid request with the same message the server would.

## Identity is checked at the door

Nothing in a fleet trusts a caller it has not identified. Every service gets a
SPIFFE identity under one trust domain and a token minted by one authority,
the kernel. The generated server wrapper authenticates and authorizes every
call before the handler runs, with the rules from the proto. A tenant-owned
service refuses a caller from another tenant before any code of yours is
reached. There is no hand-written auth to get wrong, and no way to forget it.

## State has one owner

A service declares the state it owns. Live state the whole fleet needs to see
is hosted in the kernel and watched, not polled. Durable records are written
once onto the event bus and stored by stratum; publishing the record is
writing it, and the read plane is read-only. Bytes go to the blob store. No
service reaches into another's store, because the generated clients do not
offer a way to.

## Three languages, one capability

Go, Rust and Java are full-service languages, and a capability that exists in
one must exist in the others. Shape may differ to fit the language; capability
may not. A gap is a defect, not a roadmap item. TypeScript, Python, Swift and
C# are client languages and get the client surfaces. This is what lets a fleet
pick the right language per service without losing anything.

## Any piece can be replaced

The [registry](https://github.com/tacplus-dev/registry) decides a service's
name and permanent id and says where its proto lives. It never decides which
implementation a fleet runs. That is the fleet manifest's choice, so a fleet
may run its own kernel, open or closed, under the same name and number, and
every other service keeps working because they were generated against the
contract, not the implementation. The open set here is what it takes to stand
up and run a cluster; what you build on it is yours.

## What it is not

tacplus is not a framework you call into. Your code is the handler; the
generated code calls you. It is not a service mesh bolted on afterwards; the
mesh is generated from the same proto as the service. And it is not finished.
The platform services came out of a private tree in October 2026 and are being
reworked in the open. Each README says where it stands.

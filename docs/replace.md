---
description: How a fleet runs its own implementation of a tacplus service, open or closed, under the same name and id, and what the registry does and does not decide.
---

# Replace a piece

Everything under tacplus-dev is what it takes to stand up and run a cluster.
Nothing about it requires you to run our implementation of any of it. A fleet
may run its own kernel, its own gateway, its own policy engine, open or
closed, and every other service keeps working. This is designed in, not
tolerated.

## What the registry decides

The [registry](https://github.com/tacplus-dev/registry) is the one place
globally unique ids come from. Each entry has a name, an id, and a contract:
the repository that holds the service's proto. The id is a field number in the
generated entitlements message and a value in the service-name enum, so two
services anywhere may never share one. Ids are never reused and never
renumbered.

That is all the registry decides. In its own words, it decides ids, not who
may read what, and never which implementation a fleet runs. An entry's
contract repository may be public, shared with one partner, or private; the
registry carries a visibility flag so a fleet owner knows which, and nothing
more.

## What the fleet manifest decides

The `fleet.yaml` in a deployment repository names, for each service, the
repository that implements it:

```yaml
services:
  - name: kernel
    repo: https://github.com/acme/our-kernel.git   # the implementation THIS fleet runs
```

The fleet build fetches that repository at the version the manifest pins,
reads its proto, and checks two things: the proto declares the registered name,
and its id lock carries the registry's id. A fleet may run its own kernel. It
may never run it under a different number, because every other service in the
fleet was generated against that number.

From there the replacement is invisible. The other services were generated
against the contract, the proto, not against our code. Their clients call the
name; the gateway routes by the name; the kernel mints tokens with the name as
audience. Whose binary answers is the manifest's business.

## What a replacement must do

A replacement implements the contract. For a service that means the rpcs in
its proto, with the annotations the proto carries: a replacement kernel still
has to be the token authority at the routing label `kernel`, still has to host
the `kernel`-labelled state roots, still has to implement the system minter
contract every generated ServiceManager calls. The generated server wrapper
in whatever language you choose gives you the authentication, authorization
and validation for free; the handler is where your implementation lives.

A replacement may extend the proto, as long as the generated surfaces the
rest of the fleet depends on are still there. It may be written in any
full-service language. It may be closed. The fleet build does not care, and
neither does anything generated from it.

## Why this matters

The open set is a working platform, and we run it. But a platform you cannot
replace a piece of is a platform you do not control. Someone building on
tacplus should be able to swap the piece that does not fit their regulator,
their vendor, or their threat model, and keep the rest. Someone selling on
tacplus should be able to keep their product closed while standing on an open
fleet. The registry and manifest split is what makes both true with one
mechanism.

The private tree these services came out of still runs its own fleet. That
fleet is the first instance of this rule: same names, same ids, the
implementations it chooses.

---
description: Stand up a tacplus fleet on a disposable cluster with fleet-seatrials, create two tenants, and watch tenantecho answer for each.
---

# Run a fleet

The fastest way to understand tacplus is to run one. The proof fleet,
[fleet-seatrials](https://github.com/tacplus-dev/fleet-seatrials), stands up
the whole platform on a small, disposable GKE cluster, deploys a tenant-owned
service into two tenants, and proves that each tenant's call reaches that
tenant's instance. The cluster is created for a trial and destroyed after it.
Nothing in it is long-lived.

Its README is the authority on the exact commands; this page explains what
each step is doing and why.

## What a fleet is, on disk

A deployment repository holds one `fleet.yaml`:

```yaml
registries:
  - https://github.com/tacplus-dev/registry.git
tacplus: "2.2"
services:
  - name: kernel
    repo: https://github.com/tacplus-dev/kernel.git
  - name: gateway
    repo: https://github.com/tacplus-dev/gateway.git
  - name: tenantecho
    repo: https://github.com/tacplus-dev/tenantecho.git
  # ... every service the fleet runs, with the repository that implements it
```

Three things are in it: the registries the fleet trusts for names and ids, the
`MAJOR.MINOR` of tacplus it is built with, and for every service the
repository that implements it. That last line is the whole override story: the
registry fixed the name and id, the manifest picks the code.

`tacplus fleet build` turns that into `fleet.lock`, the exact commit of every
registry and service, and `build/proto`, the merged proto tree every
fleet-side artifact is generated from. The build refuses a fleet with a
missing dependency, a service under the wrong id, or a proto that does not
declare its registered name.

## The sequence

**1. Create the cluster.** A small, zonal, disposable GKE cluster. The script is
a few lines of `gcloud`.

**2. Initialize the PKI.** The fleet's operator is built from the operator
library against this fleet's merged protos, so the binary knows exactly which
services it renders. Its `init` subcommands create the fleet CA and the cluster
signing CA that kmaker will use. The key material lands in a `crypto.yaml`
that is never committed; the topology in `operator.yaml` is.

**3. Build the images.** One image per service, from the exact commit the lock
names, generated against this checkout's merged protos, built in Cloud Build
and pushed to the fleet's registry. Every Java image runs under the launcher.

**4. Apply.** The operator renders a Helm chart per service and applies them.
The boot order follows the identity story in
[How a fleet works](how.md): kmaker signs the kernel's certificate, the kernel
starts hosting state and configuration, every other service bootstraps
through its generated ServiceManager against the kernel, letsencrypt obtains
the public certificate, the gateway starts routing.

**5. Become root.** The local client generates a credential pair. Its public
half goes into the operator's config as a root credential pair and the fleet
is applied again. From then on the client can log in as root through the
gateway and administer tenants, before any user or identity provider exists.

**6. Create two tenants.** Root creates `alpha` and `beta`, and a credential
pair for each. The operator sees the new tenant records in kernel state and
renders a tenant-owned instance of every tenant-owned service for each one:
`tenantecho-alpha`, `tenantecho-beta`, and the same for doppelganger.

**7. Prove the routing.** Log in as alpha and ping. The reply names the tenant
that served it and the tenant that called. Log in as beta and ping again. If
the gateway ever routed a call to the wrong tenant's instance, the response
would say so itself.

**8. Prove a real service.** Push context into alpha's doppelganger and ask it
a question. The answer comes back through the gateway from alpha's instance,
which got its completion from llmproxy, the only service in the fleet that
holds a model-vendor identity.

**9. Destroy.** One script. The fleet leaves nothing behind but the repository.

## What you need

A Google Cloud project with GKE, Cloud Build and Artifact Registry, `gcloud`,
`kubectl`, Go, and a DNS name for the gateway if you want a public certificate.
The seatrials fleet uses a real hostname and Let's Encrypt, so the fleet is a
real OIDC issuer that outside systems can trust.

## After the trial

A real deployment is the same shape with a longer life: a deployment
repository of its own, a `fleet.yaml` naming the services it runs and where
each comes from, an operator built from the library, and the pin rule in
[Project](project.md) for what version of each piece it follows.
[Build a service](build.md) is how you add your own to the manifest, and
[Replace a piece](replace.md) is how you swap one of ours.

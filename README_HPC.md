# VirtualBrainTwin

## Creating new cache for VBT Spack Environment

## Version environment variables

Three environment variables control the version of the caches and of the kernel. They are defined as
CI/CD variables in GitLab and **must be set whenever a new version is needed.

| Variable | Controls | Default |
|---|---|---|
| `CONCRETIZE_OCI_VERSION` | Version of the concretization cache | rocky_hpc_v4.3 |
| `BUILDCACHE_OCI_VERSION` | Version of the binary (build) cache | rocky_hpc_v4.3 |
| `KERNEL_VERSION` | Version of the JupyterLab kernel | v4.3 |

Each of the three must be initialized with a default value. If they are left unset, the pipeline
does not produce a new version.

## Updating the cache

The cache is rebuilt by a **GitLab pipeline schedule that runs on monthly**. The scheduled
pipeline sets `OPERATION=cache`, which is what enables the cache-building jobs:

```yaml
rules:
  - if: '$CI_PIPELINE_SOURCE == "schedule" && $OPERATION == "cache"'
```

Two jobs run under that rule — `build-cache-ubuntu-local` (Ubuntu / Docker runner; most likely deprecated in the latest updated. It was commented out from the CI/CD pipeline)  and
`build-cache-rocky-hpc` (Rocky / JUWELS shell runner at JSC). Both have a 72 hour timeout.

The schedule can also be **triggered manually**: go to *Build → Pipeline schedules* in GitLab and
run the relevant schedule. This is the way to force a cache rebuild without waiting for the monthly
run — for example after bumping one of the version variables above.

> **The Harbor registry has to be cleaned from time to time.** Every cache version accumulates
> artifacts in the OCI registry and they are never removed automatically. Without periodic cleanup
> the registry keeps growing and eventually runs out of quota.

## Creating the JupyterLab kernel on the JSC HPC

Once the cache pipeline has completed **successfully**, create a **new release** in GitLab. Tagging is
what drives the HPC deployment — the release jobs are gated on `$CI_COMMIT_TAG`.

The release triggers, in order:

1. `install-vbt-spack-env-hpc` — installs the Spack environment on the JSC HPC from the cache that
   the scheduled pipeline produced.
2. `release-vbt-kernel` — builds and deploys the JupyterLab kernel (EasyBuild bundle wrapping the
   Spack view, registered as a Jupyter kernel).

So the full sequence is: **increase the version variables → run the cache schedule → confirm it passed →
create a release → the Spack environment is installed and the JupyterLab kernel is deployed.**

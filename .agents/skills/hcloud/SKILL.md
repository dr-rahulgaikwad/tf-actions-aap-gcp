---
name: hcloud
description: "Guide for hcloud — HashiCorp's internal CLI for HCP development workflows. Use when working with hcloud commands, plugins (prde, service, localdb, hashistack, letmein, pproxy), PRDE lifecycle management, local database setup, deploying services, connecting to hashistack environments, requesting access via doormat/letmein, or proxying through passport."
---

# hcloud — HashiCorp Internal CLI

## Overview

`hcloud` is HashiCorp's internal CLI for managing HCP development workflows. It is plugin-based; most functionality lives in separately installed plugins.

**Installation** (macOS via Homebrew):

```bash
brew tap hashicorp/internal
brew install hcloud
```

**Update:**

```bash
brew upgrade hcloud
```

### Core Commands

```bash
hcloud version                  # Show hcloud and plugin versions
hcloud plugin list              # List installed plugins
hcloud plugin install <name>    # Install a plugin
hcloud plugin upgrade <name>    # Upgrade a plugin
hcloud plugin uninstall <name>  # Uninstall a plugin
hcloud plugin search <query>    # Search available plugins
hcloud plugin info <name>       # Show plugin details
```

**Global flags:**

- `--help` / `-h` — Show help for any command
- `--debug` — Enable debug output

---

## Plugin: prde (Personal Remote Dev Environment)

PRDE is a personal cloud dev environment for testing service changes end-to-end.

### Commands

```bash
hcloud prde create              # Provision a new PRDE
hcloud prde init                # Initialize PRDE configuration
hcloud prde up                  # Start PRDE (create + init combined)
hcloud prde run                 # Deploy local changes to PRDE
hcloud prde connect             # Open SSH tunnel / port-forward to PRDE services
hcloud prde proxy               # Start a local proxy to PRDE
hcloud prde deploy              # Deploy a specific service to PRDE
hcloud prde session             # Start an interactive session in PRDE
hcloud prde health              # Check PRDE health status
hcloud prde restart             # Restart services in PRDE
hcloud prde dashboards          # Open monitoring dashboards for PRDE
hcloud prde deactivate          # Temporarily deactivate PRDE (save costs)
hcloud prde reactivate          # Reactivate a deactivated PRDE
hcloud prde purge               # Remove PRDE data (keep infra)
hcloud prde nuke                # Destroy PRDE completely
```

### Proxy Local Endpoints

When `hcloud prde proxy` is running, all PRDE services are available locally:

| Service           | URL / connection string                                                     |
| ----------------- | --------------------------------------------------------------------------- |
| portal            | http://localhost:8000                                                       |
| admin             | http://localhost:14200                                                      |
| api               | http://localhost:28081                                                      |
| cadence           | http://localhost:7940/domain/hcp/workflows                                  |
| jaeger            | http://localhost:16686                                                      |
| nomad-ui          | http://localhost:4646                                                       |
| traefik-dashboard | http://localhost:28080                                                      |
| localstack        | http://localhost:4566                                                       |
| dynamodb          | http://localhost:9002                                                       |
| minio             | http://localhost:9000                                                       |
| vault             | http://localhost:8200                                                       |
| consul            | http://localhost:8500                                                       |
| postgres          | `psql postgres://<user>:<password>@localhost:5432/postgres?sslmode=disable` (default user/password: `postgres`/`postgres`) |
| mysql             | `mysql --host=127.0.0.1 --user=<user> --password=<password>` (default user/password: `root`/`root`)                       |

### Development Loop

```bash
# 0. If deploying from a branch, sync vendor directory first
go work vendor

# 1. Ensure the Doormat Docker credential helper is configured (one-time setup)
#    Install: https://github.com/hashicorp/docker-credential-doormat
#    Once installed, Docker authenticates to Artifactory automatically via Doormat.

# 2. Terminal 1: start PRDE proxy (exposes all services locally, see endpoint table above)
hcloud prde proxy

# 3. Terminal 2: build and deploy to PRDE
hcloud prde run

# 4. Iterate: make code changes, then re-run step 3
```

**Common `hcloud prde run` failures:**

| Error                                              | Fix                                                                               |
| -------------------------------------------------- | --------------------------------------------------------------------------------- |
| `inconsistent vendoring`                           | Run `go work vendor`                                                              |
| `Token failed verification: expired` (docker push) | Verify `docker-credential-doormat` is installed and configured (see step 1 above) |
| `could not connect to the Nomad API`               | Start proxy first: `hcloud prde proxy`                                            |

### Datadog Logs

Run `hcloud prde dashboards` to get direct Datadog links for your PRDE:

```
## PRDE Datadog Dashboards
* PRDE overview:   https://hashicorp-cloud.datadoghq.com/dashboard/jth-6a2-42x?tpl_var_prde_profile[0]=<username>
* Containers:      https://hashicorp-cloud.datadoghq.com/containers?query=prde_profile:<username>
* Infrastructure:  https://hashicorp-cloud.datadoghq.com/infrastructure?tags=prde_profile:<username>
* Logs:            https://hashicorp-cloud.datadoghq.com/logs?query=index:cloud-personal-dev%20prde_profile:<username>
```

PRDE logs live in the **`cloud-personal-dev`** index (not the standard `env:dev` shared index). The correct Datadog filter:

```
index:cloud-personal-dev prde_profile:<username>
```

---

## Plugin: service

Manages CI/CD deployments and service operations.

```bash
hcloud service deploy           # Deploy a service to an environment
hcloud service plan             # Preview deployment changes
hcloud service job-render       # Render Nomad job definitions
hcloud service job-list         # List running jobs
hcloud service migrate          # Run database migrations in an environment
hcloud service init             # Initialize service configuration
hcloud service breakglass       # Emergency access / break-glass procedure
hcloud service freeze           # Freeze deployments for a service
hcloud service lock             # Lock a service from changes
hcloud service dispatch         # Dispatch a parameterized Nomad job
hcloud service tags             # Manage deployment tags
hcloud service signal           # Send a signal to running service instances
```

---

## Plugin: localdb

Starts a local database for testing (used instead of a remote test DB).

```bash
# Start local PostgreSQL
hcloud localdb --family=postgres

# Specify major version
hcloud localdb --family postgres --major-version 16

# Start local MySQL
hcloud localdb --family=mysql
```

**Flags:**

- `--family` — **(required)** Database family: `postgres` or `mysql`
- `--major-version` — Major version number (e.g., `14`, `15`, `16`)
- `--port` — Override default port
- `--database` — Override default database name
- `--tempfs-size-mb` — Size of the tmpfs volume in MB (default: `512`)
- `--migrations` — Path to golang-migrate migrations directory (default: `./models/migrations`)

---

## Plugin: hashistack

Connects to and manages HashiCorp internal stack environments (staging, prod, etc.).

```bash
hcloud hashistack connect <stack>       # Connect to a named stack (alias: vpn)
hcloud hashistack disconnect <stack>    # Disconnect from a stack (alias: shutdown)
hcloud hashistack env <stack>           # Print environment variables for a stack
hcloud hashistack init                  # Initialize hashistack configuration
hcloud hashistack tokens                # Manage stack tokens
hcloud hashistack prefs                 # Manage preferences
hcloud hashistack list                  # List available stacks
hcloud hashistack get <stack> <key>     # Get a value from a stack
```

**Common stacks:**

- `hcp-dev-iad`, `hcp-dev-pdx`, `hcp-dev-dub`, `hcp-dev-fra` — Development environments
- `hcp-int-iad`, `hcp-int-pdx`, `hcp-int-dub`, `hcp-int-fra` — Integration environments
- `hcp-prod-iad`, `hcp-prod-pdx`, `hcp-prod-dub`, `hcp-prod-fra` — Production environments

**Usage example:**

```bash
hcloud hashistack connect hcp-int-iad
eval "$(hcloud hashistack env hcp-int-iad)"
```

---

## Plugin: letmein

Requests or removes temporary access via Doormat to AWS accounts or GitHub repos.

```bash
hcloud letmein --justification="<reason>" [--access-level=<level>] [--ttl=<duration>] [--delete] <ITEM>
```

**Item format:**

- `aws:<account_name>` or `aws:<account_id>` — AWS account (bare name also works for backwards compatibility)
- `github:[<owner>/]<repo>` — GitHub repo (owner defaults to `hashicorp`)

**Flags:**

- `-j` / `--justification` — **(required)** Why you need access
- `-l` / `--access-level` — Access level; defaults to lowest available
  - AWS: `viewer`, `session`, `developer`, `admin`
  - GitHub: `read`, `triage`, `write`, `maintain`, `admin`, `owners`
- `--ttl` — Access duration (e.g., `1h`, `8h`, `90d`; default `12h`)
- `-d` / `--delete` — Remove access instead of granting it

**Examples:**

```bash
# Request default (viewer) access to cloud_dev AWS account
hcloud letmein --justification="debugging prod issue" aws:cloud_dev

# Request developer access with custom TTL
hcloud letmein --justification="testing" --access-level=developer --ttl=4h aws:cloud_dev

# Request read access to a GitHub repo
hcloud letmein --justification="reviewing code" github:hashicorp/hcloud

# Remove access
hcloud letmein --justification="done" --delete aws:cloud_dev
```

---

## Plugin: pproxy

Passport proxy — allows accessing remote HCP services without VPN by routing traffic through a passport-authenticated proxy. Services are accessible at `http://<service>.<stack>.pproxy.local`.

```bash
hcloud pproxy serve             # Start the passport proxy
```

**Flags:**

- `-d` / `--debug` — Enable debug logging
- `-o` / `--overwrite` — Overwrite existing plugin config

**Usage:** Run `hcloud pproxy serve` before making calls to remote HCP services from local code. Services are then available at URLs like `http://vault.hcp-dev-iad.pproxy.local`.

---

## Common Workflows

### Local development loop (unit tests)

```bash
hcloud localdb --family=postgres    # Terminal 1: start local DB
make go/test                        # Terminal 2: run tests
```

### Connect to a hashistack environment

```bash
hcloud hashistack connect hcp-int-iad
eval "$(hcloud hashistack env hcp-int-iad)"
# Now environment variables point to hcp-int-iad stack
```

### Request temporary AWS access

```bash
hcloud letmein --justification="<reason>" --access-level=read --ttl 2h aws:<account-name>
```

### Access remote services locally (no VPN)

```bash
hcloud pproxy serve
# Services available at http://<service>.<stack>.pproxy.local
# e.g. http://vault.hcp-dev-iad.pproxy.local
```

---

## Troubleshooting

### `hcloud hashistack connect` fails with "sshuttle failed to start"

`hcloud hashistack connect` uses `sshuttle` to set up network routes, which requires sudo. If you get repeated `exit status 99` errors, sshuttle cannot prompt for a password. Run the command from an interactive terminal where sudo can prompt normally.

> **Agent note:** Do not run `hcloud hashistack connect` on behalf of the user. Instead, inform the user that this command must be run directly in a terminal, as it requires an interactive sudo password prompt.

---

## Tips

- Run `hcloud <plugin> --help` for full flag documentation on any subcommand
- Run `hcloud plugin upgrade --all` to update all plugins at once
- PRDE environments incur cloud costs — use `hcloud prde deactivate` when not in use
- `hcloud prde nuke` is destructive and non-reversible; prefer `deactivate` for temporary pauses
- Plugin versions are independent of the hcloud binary version; upgrade them separately
- Artifactory authentication is handled automatically by the [Doormat Docker credential helper](https://github.com/hashicorp/docker-credential-doormat) — ensure it is installed and configured

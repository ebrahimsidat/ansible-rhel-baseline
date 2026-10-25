# ansible-rhel-baseline

[![CI](https://github.com/ebrahimsidat/ansible-rhel-baseline/actions/workflows/ci.yml/badge.svg)](https://github.com/ebrahimsidat/ansible-rhel-baseline/actions/workflows/ci.yml)
![Ansible](https://img.shields.io/badge/ansible--core-2.15%2B-EE0000?logo=ansible&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-RHEL%208%20%7C%209-EE0000?logo=redhat&logoColor=white)
![ansible-lint](https://img.shields.io/badge/ansible--lint-production%20profile-1F5082)
![License](https://img.shields.io/badge/license-MIT-green)

Production-grade Ansible roles for operating **Red Hat Enterprise Linux 8 and 9** fleets:
safe rolling patching, a CIS-aligned security baseline, and a read-only health assessment that
produces a consolidated fleet report. Compatible with Rocky Linux and AlmaLinux.

| Role | Purpose | Changes hosts? |
|---|---|---|
| [`rhel_patching`](roles/rhel_patching) | Pre-checks, dnf updates (all or security-only), controlled reboot, post-verification | Yes |
| [`rhel_hardening`](roles/rhel_hardening) | SSH, kernel parameters, auditd, firewalld, chrony, crypto policy, file permissions | Yes |
| [`rhel_health_check`](roles/rhel_health_check) | Disk, load, failed units, time sync and pending security errata, with Markdown and JSON reports | No (read-only) |

## Design principles

- **Safe by default.** Patching stops at the first failure (`max_fail_percentage: 0`), runs pre-checks before touching a host,
  and verifies critical services afterwards. SSH changes are validated with `sshd -t` before they are written.
- **Idempotent and reviewable.** Every role supports `--check --diff`, so changes can be reviewed before they are applied.
- **Validated inputs.** Each role ships an `argument_specs.yml`, so wrong variable types or values fail fast with a clear message.
- **Traceable controls.** Hardening tasks are tagged with their CIS benchmark section; see [docs/controls.md](docs/controls.md).
- **Quality-gated.** CI runs yamllint, ansible-lint at the strict *production* profile, a syntax check of every playbook,
  and a smoke test that executes the health-check role and publishes its report.

## Quick start

```bash
python3 -m pip install ansible-core
ansible-galaxy collection install -r requirements.yml

cp -r inventories/example inventories/prod        # add your hosts and variables
ansible-playbook -i inventories/prod playbooks/health_check.yml
```

## Playbooks

| Playbook | What it does |
|---|---|
| `playbooks/health_check.yml` | Read-only assessment; writes `reports/health-report.md` and `reports/health-report.json` |
| `playbooks/harden.yml` | Applies the security baseline (`--tags ssh,sysctl` to apply selected controls) |
| `playbooks/patch.yml` | Rolling patch: application tier in 25% batches, database tier one host at a time |
| `playbooks/site.yml` | Hardening followed by a health check |

### Rolling patching

```bash
ansible-playbook -i inventories/prod playbooks/patch.yml --check            # preview
ansible-playbook -i inventories/prod playbooks/patch.yml                    # execute
ansible-playbook -i inventories/prod playbooks/patch.yml -e rhel_patching_security_only=true
```

For each host the role:

1. Confirms the OS is RHEL-family 8 or 9 and that `/var` has enough free space
2. Checks for available updates and skips hosts that are already current
3. Applies updates with `dnf`, honouring an exclude list
4. Uses `needs-restarting -r` to decide whether a reboot is required, and reboots only if allowed
5. Verifies that critical services (for example `sshd`, `chronyd`) are running before moving on

### Security baseline

```bash
ansible-playbook -i inventories/prod playbooks/harden.yml --check --diff     # review first
ansible-playbook -i inventories/prod playbooks/harden.yml
```

> Before enforcing `rhel_hardening_ssh_password_authentication: false` or `rhel_hardening_ssh_allowed_groups`,
> confirm that key-based access works for the accounts and groups that need it.

### Health check as a deployment gate

```bash
ansible-playbook -i inventories/prod playbooks/health_check.yml -e rhel_health_check_fail_on_critical=true
```

A [sample report](docs/sample-health-report.md) shows the output format.

## Configuration

Every variable is documented in each role's `defaults/main.yml` and validated by `meta/argument_specs.yml`.
Common settings:

| Variable | Default | Description |
|---|---|---|
| `rhel_patching_security_only` | `false` | Apply only security errata |
| `rhel_patching_exclude_packages` | `[]` | Package patterns never updated |
| `rhel_patching_reboot_allowed` | `true` | Reboot when required |
| `rhel_patching_services_to_verify` | `[sshd]` | Services that must be running after patching |
| `rhel_hardening_ssh_allowed_groups` | `[]` | Restrict SSH logins to these groups |
| `rhel_hardening_crypto_policy` | `DEFAULT` | `DEFAULT`, `FUTURE` or `FIPS` |
| `rhel_health_check_disk_warn_percent` / `_crit_percent` | `80` / `90` | Disk usage thresholds |
| `rhel_health_check_fail_on_critical` | `false` | Fail the run when any host is critical |

## Repository layout

```text
.
├── ansible.cfg
├── requirements.yml              # ansible.posix, community.general
├── inventories/example/          # sample inventory and group variables
├── playbooks/                    # patch, harden, health_check, site
├── roles/
│   ├── rhel_patching/
│   ├── rhel_hardening/
│   └── rhel_health_check/
└── docs/                         # control mapping and sample report
```

## Development

```bash
make lint      # yamllint + ansible-lint (production profile)
make syntax    # syntax-check all playbooks
```

## License

Released under the [MIT License](LICENSE). © 2026 Ebrahim Sidat.

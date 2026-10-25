# Security control mapping

The `rhel_hardening` role implements a subset of the CIS Red Hat Enterprise Linux 8 and 9 Benchmarks
that is safe to apply broadly without application-specific tuning. Each control area is tagged so it can
be applied or audited on its own, for example `--tags cis_5.2`.

| CIS section | Area | Implementation | Tag |
|---|---|---|---|
| 1.1.1 | Disable unused file systems | `cramfs`, `squashfs`, `udf` blocked in `/etc/modprobe.d/90-disabled-filesystems.conf` | `cis_1.1.1` |
| 1.7 | Warning banners | `/etc/issue` and `/etc/issue.net`; referenced by sshd `Banner` | `cis_1.7` |
| 1.10 | System-wide crypto policy | `update-crypto-policies` set to `DEFAULT`, `FUTURE` or `FIPS` | `cis_1.10` |
| 3.2 / 3.3 | Network parameters | IP forwarding, redirects, source routing, reverse-path filtering, SYN cookies, martian logging, IPv6 router advertisements | `cis_3.2`, `cis_3.3` |
| 4.1 | Auditing | `auditd` enabled; rules for identity files, sudoers, sshd configuration, login records, time changes and kernel modules | `services` |
| 5.2 | SSH server | Root login, password and empty-password authentication, host-based auth, X11 forwarding, `MaxAuthTries`, idle timeouts, `LoginGraceTime`, verbose logging, optional `AllowGroups` | `cis_5.2` |
| 6.1 | File permissions | Ownership and mode of `/etc/passwd`, `/etc/group`, `/etc/shadow`, `/etc/gshadow` | `cis_6.1` |
| — | Host firewall and time sync | `firewalld` and `chronyd` installed, enabled and running | `services` |

## Scope and limitations

- Controls that depend on site policy (partitioning, password complexity, account lockout, log forwarding
  destinations, SELinux policy changes) are intentionally out of scope and should be layered on per environment.
- The role is a baseline, not a certification. Validate compliance with an authoritative scanner such as
  OpenSCAP (`oscap xccdf eval --profile cis ...`) after applying it.

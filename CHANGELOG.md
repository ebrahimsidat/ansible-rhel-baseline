# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-25

### Added

- rhel_patching role: pre-checks, dnf updates with security-only option, controlled reboot and service verification
- rhel_hardening role: CIS-aligned SSH, kernel, audit, firewall, time sync, crypto policy and file permission controls
- rhel_health_check role: read-only fleet assessment with Markdown and JSON reports and an optional CI/CD gate
- Rolling patch playbook with tiered batching and fail-fast behaviour
- Argument specifications for input validation on every role
- CI pipeline: yamllint, ansible-lint production profile, syntax checks and a live health-check smoke test

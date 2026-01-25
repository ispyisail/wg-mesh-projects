---
name: Bug Report
about: Report a bug or issue
title: '[BUG] '
labels: bug
assignees: ''
---

## Package

- [ ] wg-mesh-manager (core)
- [ ] wg-mesh-discovery (module)
- [ ] Both / General

## Severity

- [ ] Critical - System unusable
- [ ] High - Major feature broken
- [ ] Medium - Workaround exists
- [ ] Low - Minor/cosmetic

## Bug Description

A clear description of the bug.

## Environment

**Version:**
```bash
mesh-version
# Paste output here
```

**Platform:**
- Router Model: (e.g., Archer C7 v2)
- Firmware: (e.g., OpenWrt 21.02)
- Architecture: (e.g., ar71xx, x86_64)

## Steps to Reproduce

1.
2.
3.

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Reproducibility

- [ ] Always (100%)
- [ ] Often (>50%)
- [ ] Sometimes (<50%)
- [ ] Unable to reproduce reliably

## Logs

<details>
<summary>Diagnostic output (click to expand)</summary>

```bash
# Mesh status
mesh-status

# WireGuard status
wg show

# Health check
mesh-health

# System logs
logread | grep -E 'wg-mesh|wireguard' | tail -100
```

</details>

## Additional Context

Any other relevant information.

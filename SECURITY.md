# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

### Contact

Email: security@your-domain.com

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Affected versions
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **48 hours:** Initial acknowledgment
- **7 days:** Assessment and severity determination
- **90 days:** Target fix timeline (may vary by severity)

## Scope

### In Scope

- wg-mesh-manager package
- wg-mesh-discovery package
- Official documentation

### Out of Scope

- Third-party dependencies (report to upstream)
- Social engineering attacks
- Denial of service attacks

## Safe Harbor

We consider security research conducted in good faith to be:

- Authorized concerning any applicable anti-hacking laws
- Exempt from DMCA restrictions on circumvention
- Lawful, helpful, and in the interest of users

We will not pursue legal action against researchers who:

- Act in good faith
- Avoid privacy violations and data destruction
- Report findings before public disclosure

## Security Best Practices

### For Users

1. **Keep Updated:** Use the latest version
2. **Secure Keys:** Never share private WireGuard keys
3. **Firewall:** Configure firewall rules properly
4. **Backups:** Encrypt backup files containing keys
5. **Access:** Limit router access

### For Developers

1. **Input Validation:** Validate and sanitize all inputs
2. **No Secrets:** No hardcoded credentials
3. **Secure Defaults:** Conservative configurations
4. **Least Privilege:** Minimum necessary permissions
5. **Review:** All changes require review

## Disclosure Policy

We disclose after:

1. Fix is available
2. Users have reasonable time to update
3. Reporter agrees (or 90 days pass)

Credit given unless anonymity preferred.

## Known Issues

None currently.

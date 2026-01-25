# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-25

### Added

- Initial release of WireGuard Mesh Projects
- **wg-mesh-manager** - Core mesh networking package
  - Automated WireGuard mesh setup
  - Peer management (add/remove/update)
  - Configuration generation and distribution
  - Backup and recovery functionality
  - Health monitoring and status commands
- **wg-mesh-discovery** - Device discovery module
  - Multi-method discovery (ARP, NMAP, mDNS)
  - DNS integration with dnsmasq
  - Device type identification
  - Cross-mesh synchronization
- Development infrastructure
  - GitHub Actions CI/CD workflows
  - Automated testing framework
  - Release automation
- Documentation
  - Quick start guides
  - Troubleshooting guides
  - API reference

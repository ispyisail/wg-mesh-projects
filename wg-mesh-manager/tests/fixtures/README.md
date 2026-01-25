# Test Fixtures

Sample configuration files for testing WireGuard Mesh Manager.

## Files

- `mesh.conf.sample` - Sample mesh configuration
- `peers.db.sample` - Sample peers database
- `wg-mesh.conf.sample` - Sample generated WireGuard config

## Usage

These fixtures are used by the test scripts to validate functionality
without requiring actual WireGuard installation.

```bash
# Copy to test environment
cp fixtures/mesh.conf.sample /tmp/test-wg-mesh/mesh.conf
cp fixtures/peers.db.sample /tmp/test-wg-mesh/peers.db
```

## Note

The keys in these samples are not valid WireGuard keys.
For actual testing, generate real keys:

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

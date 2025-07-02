[![codecov](https://codecov.io/gh/ethicnology/dart-bip32-keys/graph/badge.svg?token=J6E7XAI0FR)](https://codecov.io/gh/ethicnology/dart-bip32-keys)

# bip32_keys

A [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) library with [SLIP132](https://github.com/satoshilabs/slips/blob/master/slip-0132.md) support for Dart/Flutter community.

## Example

See `example/bip32_keys_example.dart` for a complete usage example.


## Supported SLIP-132 Formats

| Format | Description | Network |
|--------|-------------|---------|
| `xpub` | Legacy P2PKH | Bitcoin Mainnet |
| `ypub` | P2SH-P2WPKH | Bitcoin Mainnet |
| `Ypub` | P2SH-P2WSH | Bitcoin Mainnet |
| `zpub` | P2WPKH | Bitcoin Mainnet |
| `Zpub` | P2WSH | Bitcoin Mainnet |
| `tpub` | Legacy P2PKH | Bitcoin Testnet |
| `upub` | P2SH-P2WPKH | Bitcoin Testnet |
| `Upub` | P2SH-P2WSH | Bitcoin Testnet |
| `vpub` | P2WPKH | Bitcoin Testnet |
| `Vpub` | P2WSH | Bitcoin Testnet |

## Usage

```dart
import 'package:bip32_keys/bip32_keys.dart';

void main() {
  const xprv =
      'xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi';
  final masterKey = Bip32Keys.fromBase58(xprv);

  print('Master key (xpub): ${masterKey.toBase58()}');
  print('Master key (WIF): ${masterKey.toWIF()}');

  // Derive a child key
  final childKey = masterKey.derive(0);
  print('Child key: ${childKey.toBase58()}');

  // Derive a hardened child key
  final hardenedChildKey = masterKey.deriveHardened(0);
  print('Hardened child key: ${hardenedChildKey.toBase58()}');

  // Derive a path
  final pathKey = masterKey.derivePath("m/44'/0'/0'/0/0");
  print('Path key: ${pathKey.toBase58()}');

  // Get neutered version (public only)
  final neuteredKey = masterKey.neutered;
  print('Neutered key: ${neuteredKey.toBase58()}');

  // SLIP-132 integration examples
  print('\n=== SLIP-132 Examples ===');

  // Convert to different SLIP-132 formats
  print('zpub format: ${neuteredKey.toSlip132(Slip132Format.zpub)}');
  print('ypub format: ${neuteredKey.toSlip132(Slip132Format.ypub)}');

  // Get fingerprints in different formats
  print(
      'Fingerprint (xpub): ${neuteredKey.getSlip132Fingerprint(Slip132Format.xpub)}');
  print(
      'Fingerprint (zpub): ${neuteredKey.getSlip132Fingerprint(Slip132Format.zpub)}');
  print(
      'Parent fingerprint: ${neuteredKey.getSlip132ParentFingerprint(Slip132Format.xpub)}');

  // Create from existing xpub
  final existingXpub =
      "xpub6DJwRncrB8eNrzUq8XxgjwCZsEeWP8FeqBJbJQZ8JfuDwLdAzyjhHiHJieNuar1wjQTyihhMWtaKGE4DUd8uBgtyrNJqF5drwbNVUqb83b7";
  final importedKey = Bip32Keys.fromBase58(existingXpub);

  print('\n=== Imported Key Examples ===');
  print('Original xpub: $existingXpub');
  print('Converted to zpub: ${importedKey.toSlip132(Slip132Format.zpub)}');
  print(
      'Fingerprint: ${importedKey.getSlip132Fingerprint(Slip132Format.xpub)}');
}
```

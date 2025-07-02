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

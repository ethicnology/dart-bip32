import 'dart:typed_data';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:hex/hex.dart';
import 'bip32_keys_base.dart';
import 'enums.dart';

/// SLIP-132 extensions for Bip32Keys
extension Slip132Extension on Bip32Keys {
  /// Convert this key to a different SLIP-132 format
  ///
  /// [format] the target format (xpub, ypub, zpub, etc.)
  ///
  /// Returns the converted extended public key or error message
  String toSlip132(Slip132Format format) {
    if (isNeutered) {
      return changeVersionBytes(toBase58(), format);
    } else {
      return "Cannot convert private key to SLIP-132 format";
    }
  }

  /// Get the SLIP-132 fingerprint for this key
  ///
  /// [format] the target format for version bytes
  ///
  /// Returns the fingerprint as hex string
  String getSlip132Fingerprint(Slip132Format format) {
    if (isNeutered) {
      return getFingerprint(toBase58(), format);
    } else {
      return "Cannot get fingerprint from private key";
    }
  }

  /// Get the SLIP-132 parent fingerprint for this key
  ///
  /// [format] the target format for version bytes
  ///
  /// Returns the parent fingerprint as hex string
  String getSlip132ParentFingerprint(Slip132Format format) {
    if (isNeutered) {
      return getParentFingerprint(toBase58(), format);
    } else {
      return "Cannot get parent fingerprint from private key";
    }
  }
}

/// Change version bytes of an extended public key
///
/// This function takes an extended public key (with any version bytes, it doesn't need to be an xpub)
/// and converts it to an extended public key formatted with the desired version bytes
///
/// [xpub] an extended public key in base58 format. Example: xpub6CpihtY9HVc1jNJWCiXnRbpXm5BgVNKqZMsM4XqpDcQigJr6AHNwaForLZ3kkisDcRoaXSUms6DJNhxFtQGeZfWAQWCZQe1esNetx5Wqe4M
/// [targetFormat] the desired SLIP-132 format
///
/// Returns the converted extended public key or error message
String changeVersionBytes(String xpub, Slip132Format targetFormat) {
  // trim whitespace
  xpub = xpub.trim();

  try {
    final data = bs58check.decode(xpub);
    final dataWithoutVersion = data.sublist(4); // Remove original version bytes
    final newVersionBytes = HEX.decode(targetFormat.prefix);
    final combinedData = [...newVersionBytes, ...dataWithoutVersion];
    final finalData = Uint8List.fromList(combinedData);
    return bs58check.encode(finalData);
  } catch (err) {
    rethrow;
  }
}

/// Get fingerprint from extended public key
///
/// [xpub] the extended public key
/// [targetFormat] the target format for version bytes
///
/// Returns the fingerprint as hex string
String getFingerprint(String xpub, Slip132Format targetFormat) {
  try {
    final convertedXpub = changeVersionBytes(xpub, targetFormat);
    final networkType = NetworkType(
      wif: targetFormat.wif,
      bip32: targetFormat.bip32,
    );
    final bip32Key = Bip32Keys.fromBase58(convertedXpub, network: networkType);
    return HEX.encode(bip32Key.fingerprint);
  } catch (err) {
    rethrow;
  }
}

/// Get parent fingerprint from extended public key
///
/// [xpub] the extended public key
/// [targetFormat] the target format for version bytes
///
/// Returns the parent fingerprint as hex string
String getParentFingerprint(String xpub, Slip132Format targetFormat) {
  try {
    final convertedXpub = changeVersionBytes(xpub, targetFormat);

    final networkType = NetworkType(
      wif: targetFormat.wif,
      bip32: targetFormat.bip32,
    );
    final bip32Key = Bip32Keys.fromBase58(convertedXpub, network: networkType);
    return bip32Key.parentFingerprint.toRadixString(16);
  } catch (err) {
    rethrow;
  }
}

/// Get depth from extended public key
///
/// [xpub] the extended public key
/// [targetFormat] the target format for version bytes
///
/// Returns the depth as integer
int getDepth(String xpub, Slip132Format targetFormat) {
  try {
    final convertedXpub = changeVersionBytes(xpub, targetFormat);

    final networkType = NetworkType(
      wif: targetFormat.wif,
      bip32: targetFormat.bip32,
    );
    final bip32Key = Bip32Keys.fromBase58(convertedXpub, network: networkType);
    return bip32Key.depth;
  } catch (err) {
    rethrow;
  }
}

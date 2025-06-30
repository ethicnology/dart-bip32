import 'dart:typed_data';

import 'package:bip32_keys/src/constants.dart';
import 'package:bip32_keys/src/enums.dart';

import 'utils/crypto.dart';
import 'utils/ecurve.dart' as ecc;
import 'package:bs58check/bs58check.dart' as bs58check;
import 'utils/wif.dart' as wif;
import 'dart:convert';

/// BIP32 Hierarchical Deterministic Key class
class Bip32Keys {
  Uint8List? _d;
  Uint8List? _q;
  Uint8List chainCode;
  int depth = 0;
  int index = 0;
  NetworkType network;
  int parentFingerprint = 0x00000000;

  /// Constructs a BIP32 key from private and public key, chain code, and network
  Bip32Keys(this._d, this._q, this.chainCode, this.network);

  /// Returns the public key
  Uint8List get public {
    _q ??= ecc.pointFromScalar(_d!, true)!;
    return _q!;
  }

  /// Returns the private key
  Uint8List? get private => _d;

  /// Returns the identifier (hash160 of public key)
  Uint8List get identifier => hash160(public);

  /// Returns the fingerprint (first 4 bytes of identifier)
  Uint8List get fingerprint => identifier.sublist(0, 4);

  /// Returns true if this key is neutered (public only)
  bool get isNeutered => _d == null;

  /// Returns a neutered (public only) version of this key
  Bip32Keys get neutered {
    final neutered =
        Bip32Keys.fromPublicKey(public, chainCode, network: network);
    neutered.depth = depth;
    neutered.index = index;
    neutered.parentFingerprint = parentFingerprint;
    return neutered;
  }

  /// Serializes the key to Base58
  String toBase58() {
    final version = !isNeutered ? network.bip32.private : network.bip32.public;
    final buffer = Uint8List(78);
    final bytes = buffer.buffer.asByteData();
    bytes.setUint32(0, version);
    bytes.setUint8(4, depth);
    bytes.setUint32(5, parentFingerprint);
    bytes.setUint32(9, index);
    buffer.setRange(13, 45, chainCode);
    if (!isNeutered) {
      bytes.setUint8(45, 0);
      buffer.setRange(46, 78, private!);
    } else {
      buffer.setRange(45, 78, public);
    }
    return bs58check.encode(buffer);
  }

  /// Serializes the private key to WIF
  String toWIF() {
    if (private == null) throw ArgumentError("Missing private key");
    return wif.encode(
      wif.WIF(
        version: network.wif,
        privateKey: private!,
        compressed: true,
      ),
    );
  }

  /// Derives a child key at the given index
  Bip32Keys derive(int index) {
    if (index > uint32Max || index < 0) throw ArgumentError("Expected UInt32");
    final isHardened = index >= highestBit;
    final data = Uint8List(37);
    if (isHardened) {
      if (isNeutered) {
        throw ArgumentError("Missing private key for hardened child key");
      }
      data[0] = 0x00;
      data.setRange(1, 33, private!);
      data.buffer.asByteData().setUint32(33, index);
    } else {
      data.setRange(0, 33, public);
      data.buffer.asByteData().setUint32(33, index);
    }
    final i = hmacSHA512(chainCode, data);
    final il = i.sublist(0, 32);
    final ir = i.sublist(32);
    if (!ecc.isPrivate(il)) {
      return derive(index + 1);
    }
    late Bip32Keys hd;
    if (!isNeutered) {
      final ki = ecc.privateAdd(private!, il);
      if (ki == null) return derive(index + 1);
      hd = Bip32Keys.fromPrivateKey(ki, ir, network: network);
    } else {
      final ki = ecc.pointAddScalar(public, il, true);
      if (ki == null) return derive(index + 1);
      hd = Bip32Keys.fromPublicKey(ki, ir, network: network);
    }
    hd.depth = depth + 1;
    hd.index = index;
    hd.parentFingerprint = fingerprint.buffer.asByteData().getUint32(0);
    return hd;
  }

  /// Derives a hardened child key at the given index
  Bip32Keys deriveHardened(int index) {
    if (index > uint31Max || index < 0) throw ArgumentError("Expected UInt31");
    return derive(index + highestBit);
  }

  /// Derives a key from a BIP32 path string
  Bip32Keys derivePath(String path) {
    final regex = RegExp(r"^(m\/)?(\d+'?\/)*\d+'?$");
    if (!regex.hasMatch(path)) throw ArgumentError("Expected BIP32 Path");
    List<String> splitPath = path.split("/");
    if (splitPath[0] == "m") {
      if (parentFingerprint != 0) {
        throw ArgumentError("Expected master, got child");
      }
      splitPath = splitPath.sublist(1);
    }
    return splitPath.fold(this, (Bip32Keys prevHd, String indexStr) {
      int index;
      if (indexStr.substring(indexStr.length - 1) == "'") {
        index = int.parse(indexStr.substring(0, indexStr.length - 1));
        return prevHd.deriveHardened(index);
      } else {
        index = int.parse(indexStr);
        return prevHd.derive(index);
      }
    });
  }

  /// Signs a hash with the private key
  sign(Uint8List hash) => ecc.sign(hash, private!);

  /// Verifies a signature with the public key
  verify(Uint8List hash, Uint8List signature) {
    return ecc.verify(hash, public, signature);
  }

  /// Constructs a BIP32 key from a Base58 string
  factory Bip32Keys.fromBase58(String string,
      {NetworkType? network, bool bypassVersion = false}) {
    final buffer = bs58check.decode(string);
    if (buffer.length != 78) throw ArgumentError("Invalid buffer length");
    network ??= bitcoin;
    ByteData bytes = buffer.buffer.asByteData();
    var version = bytes.getUint32(0);
    if (!bypassVersion &&
        (version != network.bip32.private && version != network.bip32.public)) {
      throw ArgumentError("Invalid network version");
    }
    var depth = buffer[4];
    var parentFingerprint = bytes.getUint32(5);
    if (depth == 0) {
      if (parentFingerprint != 0x00000000) {
        throw ArgumentError("Invalid parent fingerprint");
      }
    }
    var index = bytes.getUint32(9);
    if (depth == 0 && index != 0) throw ArgumentError("Invalid index");
    final chainCode = buffer.sublist(13, 45);
    late Bip32Keys hd;
    if (version == network.bip32.private) {
      if (bytes.getUint8(45) != 0x00) {
        throw ArgumentError("Invalid private key");
      }
      final k = buffer.sublist(46, 78);
      hd = Bip32Keys.fromPrivateKey(k, chainCode, network: network);
    } else {
      final x = buffer.sublist(45, 78);
      hd = Bip32Keys.fromPublicKey(x, chainCode, network: network);
    }
    hd.depth = depth;
    hd.index = index;
    hd.parentFingerprint = parentFingerprint;
    return hd;
  }

  /// Constructs a BIP32 key from a public key and chain code
  factory Bip32Keys.fromPublicKey(Uint8List publicKey, Uint8List chainCode,
      {NetworkType? network}) {
    network ??= bitcoin;
    if (!ecc.isPoint(publicKey)) {
      throw ArgumentError("Point is not on the curve");
    }
    return Bip32Keys(null, publicKey, chainCode, network);
  }

  /// Constructs a BIP32 key from a private key and chain code
  factory Bip32Keys.fromPrivateKey(Uint8List privateKey, Uint8List chainCode,
      {NetworkType? network}) {
    network ??= bitcoin;
    if (privateKey.length != 32) {
      throw ArgumentError(
          "Expected property private of type Buffer(Length: 32)");
    }
    if (!ecc.isPrivate(privateKey)) {
      throw ArgumentError("Private key not in range [1, n]");
    }
    return Bip32Keys(privateKey, null, chainCode, network);
  }

  /// Constructs a BIP32 key from a seed
  factory Bip32Keys.fromSeed(Uint8List seed, {NetworkType? network}) {
    if (seed.length < 16) {
      throw ArgumentError("Seed should be at least 128 bits");
    }
    if (seed.length > 64) {
      throw ArgumentError("Seed should be at most 512 bits");
    }
    network ??= bitcoin;
    final i = hmacSHA512(utf8.encode("Bitcoin seed"), seed);
    final il = i.sublist(0, 32);
    final ir = i.sublist(32);
    return Bip32Keys.fromPrivateKey(il, ir, network: network);
  }
}

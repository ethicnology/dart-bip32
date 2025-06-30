import 'dart:typed_data';

import 'package:bip32_keys/src/constants.dart';
import 'package:bip32_keys/src/enums.dart';

import 'utils/crypto.dart';
import 'utils/ecurve.dart' as ecc;
import 'package:bs58check/bs58check.dart' as bs58check;
import 'utils/wif.dart' as wif;
import 'dart:convert';

class Bip32Keys {
  Uint8List? _d;
  Uint8List? _Q;
  Uint8List chainCode;
  int depth = 0;
  int index = 0;
  NetworkType network;
  int parentFingerprint = 0x00000000;
  Bip32Keys(this._d, this._Q, this.chainCode, this.network);

  Uint8List get public {
    if (_Q == null) _Q = ecc.pointFromScalar(_d!, true)!;
    return _Q!;
  }

  Uint8List? get private => _d;
  Uint8List get identifier => hash160(public);
  Uint8List get fingerprint => identifier.sublist(0, 4);

  bool isNeutered() {
    return this._d == null;
  }

  Bip32Keys neutered() {
    final neutered =
        Bip32Keys.fromPublicKey(this.public, this.chainCode, this.network);
    neutered.depth = this.depth;
    neutered.index = this.index;
    neutered.parentFingerprint = this.parentFingerprint;
    return neutered;
  }

  String toBase58() {
    final version =
        (!isNeutered()) ? network.bip32.private : network.bip32.public;
    Uint8List buffer = new Uint8List(78);
    ByteData bytes = buffer.buffer.asByteData();
    bytes.setUint32(0, version);
    bytes.setUint8(4, depth);
    bytes.setUint32(5, parentFingerprint);
    bytes.setUint32(9, index);
    buffer.setRange(13, 45, chainCode);
    if (!isNeutered()) {
      bytes.setUint8(45, 0);
      buffer.setRange(46, 78, private!);
    } else {
      buffer.setRange(45, 78, public);
    }
    return bs58check.encode(buffer);
  }

  String toWIF() {
    if (private == null) {
      throw new ArgumentError("Missing private key");
    }
    return wif.encode(new wif.WIF(
        version: network.wif, privateKey: private!, compressed: true));
  }

  Bip32Keys derive(int index) {
    if (index > UINT32_MAX || index < 0)
      throw new ArgumentError("Expected UInt32");
    final isHardened = index >= HIGHEST_BIT;
    Uint8List data = new Uint8List(37);
    if (isHardened) {
      if (isNeutered()) {
        throw new ArgumentError("Missing private key for hardened child key");
      }
      data[0] = 0x00;
      data.setRange(1, 33, private!);
      data.buffer.asByteData().setUint32(33, index);
    } else {
      data.setRange(0, 33, public);
      data.buffer.asByteData().setUint32(33, index);
    }
    final I = hmacSHA512(chainCode, data);
    final IL = I.sublist(0, 32);
    final IR = I.sublist(32);
    if (!ecc.isPrivate(IL)) {
      return derive(index + 1);
    }
    Bip32Keys hd;
    if (!isNeutered()) {
      final ki = ecc.privateAdd(private!, IL);
      if (ki == null) return derive(index + 1);
      hd = Bip32Keys.fromPrivateKey(ki, IR, network);
    } else {
      final ki = ecc.pointAddScalar(public, IL, true);
      if (ki == null) return derive(index + 1);
      hd = Bip32Keys.fromPublicKey(ki, IR, network);
    }
    hd.depth = depth + 1;
    hd.index = index;
    hd.parentFingerprint = fingerprint.buffer.asByteData().getUint32(0);
    return hd;
  }

  Bip32Keys deriveHardened(int index) {
    if (index > UINT31_MAX || index < 0)
      throw new ArgumentError("Expected UInt31");
    return this.derive(index + HIGHEST_BIT);
  }

  Bip32Keys derivePath(String path) {
    final regex = new RegExp(r"^(m\/)?(\d+'?\/)*\d+'?$");
    if (!regex.hasMatch(path)) throw new ArgumentError("Expected BIP32 Path");
    List<String> splitPath = path.split("/");
    if (splitPath[0] == "m") {
      if (parentFingerprint != 0)
        throw new ArgumentError("Expected master, got child");
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

  sign(Uint8List hash) {
    return ecc.sign(hash, private!);
  }

  verify(Uint8List hash, Uint8List signature) {
    return ecc.verify(hash, public, signature);
  }

  factory Bip32Keys.fromBase58(String string,
      {NetworkType? network, bool bypassVersion = false}) {
    Uint8List buffer = bs58check.decode(string);
    if (buffer.length != 78) throw new ArgumentError("Invalid buffer length");
    network ??= BITCOIN;
    ByteData bytes = buffer.buffer.asByteData();
    // 4 bytes: version bytes
    var version = bytes.getUint32(0);
    if (!bypassVersion &&
        (version != network.bip32.private && version != network.bip32.public)) {
      throw new ArgumentError("Invalid network version");
    }
    // 1 byte: depth: 0x00 for master nodes, 0x01 for level-1 descendants, ...
    var depth = buffer[4];

    // 4 bytes: the fingerprint of the parent's key (0x00000000 if master key)
    var parentFingerprint = bytes.getUint32(5);
    if (depth == 0) {
      if (parentFingerprint != 0x00000000)
        throw new ArgumentError("Invalid parent fingerprint");
    }

    // 4 bytes: child number. This is the number i in xi = xpar/i, with xi the key being serialized.
    // This is encoded in MSB order. (0x00000000 if master key)
    var index = bytes.getUint32(9);
    if (depth == 0 && index != 0) throw new ArgumentError("Invalid index");

    // 32 bytes: the chain code
    Uint8List chainCode = buffer.sublist(13, 45);
    Bip32Keys hd;

    // 33 bytes: private key data (0x00 + k)
    if (version == network.bip32.private) {
      if (bytes.getUint8(45) != 0x00)
        throw new ArgumentError("Invalid private key");
      Uint8List k = buffer.sublist(46, 78);
      hd = Bip32Keys.fromPrivateKey(k, chainCode, network);
    } else {
      // 33 bytes: public key data (0x02 + X or 0x03 + X)
      Uint8List X = buffer.sublist(45, 78);
      hd = Bip32Keys.fromPublicKey(X, chainCode, network);
    }
    hd.depth = depth;
    hd.index = index;
    hd.parentFingerprint = parentFingerprint;
    return hd;
  }

  factory Bip32Keys.fromPublicKey(Uint8List publicKey, Uint8List chainCode,
      [NetworkType? network]) {
    network ??= BITCOIN;
    if (!ecc.isPoint(publicKey)) {
      throw new ArgumentError("Point is not on the curve");
    }
    return new Bip32Keys(null, publicKey, chainCode, network);
  }

  factory Bip32Keys.fromPrivateKey(Uint8List privateKey, Uint8List chainCode,
      [NetworkType? network]) {
    network ??= BITCOIN;
    if (privateKey.length != 32)
      throw new ArgumentError(
          "Expected property private of type Buffer(Length: 32)");
    if (!ecc.isPrivate(privateKey))
      throw new ArgumentError("Private key not in range [1, n]");
    return new Bip32Keys(privateKey, null, chainCode, network);
  }

  factory Bip32Keys.fromSeed(Uint8List seed, [NetworkType? network]) {
    if (seed.length < 16) {
      throw new ArgumentError("Seed should be at least 128 bits");
    }
    if (seed.length > 64) {
      throw new ArgumentError("Seed should be at most 512 bits");
    }
    network ??= BITCOIN;
    final I = hmacSHA512(utf8.encode("Bitcoin seed"), seed);
    final IL = I.sublist(0, 32);
    final IR = I.sublist(32);
    return Bip32Keys.fromPrivateKey(IL, IR, network);
  }
}

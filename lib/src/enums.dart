// ignore_for_file: constant_identifier_names

import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:hex/hex.dart';

class Bip32Type {
  int public;
  int private;
  Bip32Type({required this.public, required this.private});
}

class NetworkType {
  int wif;
  Bip32Type bip32;
  NetworkType({required this.wif, required this.bip32});
}

// inspired by https://github.com/jlopp/xpub-converter/blob/master/js/xpubConvert.js
enum Slip132Format {
  xpub(
    version: '0488b21e',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x0488b21e,
    bip32Private: 0x0488ade4,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  ypub(
    version: '049d7cb2',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x049d7cb2,
    bip32Private: 0x049d7878,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  Ypub(
    version: '0295b43f',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x0295b43f,
    bip32Private: 0x0295b005,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  zpub(
    version: '04b24746',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x04b24746,
    bip32Private: 0x04b2430c,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  Zpub(
    version: '02aa7ed3',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x02aa7ed3,
    bip32Private: 0x02aa7a99,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  tpub(
    version: '043587cf',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x043587cf,
    bip32Private: 0x04358394,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  upub(
    version: '044a5262',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x044a5262,
    bip32Private: 0x044a4e28,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  Upub(
    version: '024289ef',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x024289ef,
    bip32Private: 0x024285b5,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  vpub(
    version: '045f1cf6',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x045f1cf6,
    bip32Private: 0x045f18bc,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  Vpub(
    version: '02575483',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x02575483,
    bip32Private: 0x02575048,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  );

  const Slip132Format({
    required this.version,
    required this.messagePrefix,
    required this.bech32,
    required this.bip32Public,
    required this.bip32Private,
    required this.pubKeyHash,
    required this.scriptHash,
    required this.wif,
  });

  final String version;
  final String messagePrefix;
  final String bech32;
  final int bip32Public;
  final int bip32Private;
  final int pubKeyHash;
  final int scriptHash;
  final int wif;

  Bip32Type get bip32 => Bip32Type(public: bip32Public, private: bip32Private);
  NetworkType get network => NetworkType(wif: wif, bip32: bip32);

  static Slip132Format parse(String input) {
    input = input.trim();
    final bytes = bs58check.decode(input);
    final versionBytes = bytes.sublist(0, 4);
    final versionHex = HEX.encode(versionBytes);

    for (final format in Slip132Format.values) {
      if (format.version == versionHex) return format;
    }

    throw 'Invalid SLIP-132 format: $input';
  }

  static Slip132Format? tryParse(String input) {
    try {
      return parse(input);
    } catch (e) {
      return null;
    }
  }
}

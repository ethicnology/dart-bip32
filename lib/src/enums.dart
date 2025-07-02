// ignore_for_file: constant_identifier_names

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
    prefix: '0488b21e',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x0488b21e,
    bip32Private: 0x0488ade4,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  ypub(
    prefix: '049d7cb2',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x049d7cb2,
    bip32Private: 0x049d7878,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  Ypub(
    prefix: '0295b43f',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x0295b43f,
    bip32Private: 0x0295b005,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  zpub(
    prefix: '04b24746',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x04b24746,
    bip32Private: 0x04b2430c,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  Zpub(
    prefix: '02aa7ed3',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32Public: 0x02aa7ed3,
    bip32Private: 0x02aa7a99,
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
  ),
  tpub(
    prefix: '043587cf',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x043587cf,
    bip32Private: 0x04358394,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  upub(
    prefix: '044a5262',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x044a5262,
    bip32Private: 0x044a4e28,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  Upub(
    prefix: '024289ef',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x024289ef,
    bip32Private: 0x024285b5,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  vpub(
    prefix: '045f1cf6',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x045f1cf6,
    bip32Private: 0x045f18bc,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  ),
  Vpub(
    prefix: '02575483',
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32Public: 0x02575483,
    bip32Private: 0x02575048,
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
  );

  const Slip132Format({
    required this.prefix,
    required this.messagePrefix,
    required this.bech32,
    required this.bip32Public,
    required this.bip32Private,
    required this.pubKeyHash,
    required this.scriptHash,
    required this.wif,
  });

  final String prefix;
  final String messagePrefix;
  final String bech32;
  final int bip32Public;
  final int bip32Private;
  final int pubKeyHash;
  final int scriptHash;
  final int wif;

  Bip32Type get bip32 => Bip32Type(public: bip32Public, private: bip32Private);
  NetworkType get network => NetworkType(wif: wif, bip32: bip32);
}

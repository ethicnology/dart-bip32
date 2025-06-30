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

import 'package:bip32_keys/bip32_keys.dart';

final BITCOIN = new NetworkType(
    wif: 0x80, bip32: new Bip32Type(public: 0x0488b21e, private: 0x0488ade4));
const HIGHEST_BIT = 0x80000000;
const UINT31_MAX = 2147483647; // 2^31 - 1
const UINT32_MAX = 4294967295; // 2^32 - 1

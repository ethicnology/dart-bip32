import 'package:bip32_keys/bip32_keys.dart';

final bitcoin = NetworkType(
    wif: 0x80, bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4));
const highestBit = 0x80000000;
const uint31Max = 2147483647; // 2^31 - 1
const uint32Max = 4294967295; // 2^32 - 1

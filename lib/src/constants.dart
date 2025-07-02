import 'package:bip32_keys/bip32_keys.dart';

final bitcoin = Slip132Format.xpub.network;
final testnet = Slip132Format.tpub.network;

const highestBit = 0x80000000;
const uint31Max = 2147483647; // 2^31 - 1
const uint32Max = 4294967295; // 2^32 - 1

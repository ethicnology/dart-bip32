import 'dart:typed_data';
import 'package:bip32_keys/bip32_keys.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

final litecoin = NetworkType(
    bip32: Bip32Type(private: 0x019d9cfe, public: 0x019da462), wif: 0xb0);
List<dynamic> validAll = [];

void main() {
  Map<String, dynamic> fixtures = json
      .decode(File('./test/fixtures.json').readAsStringSync(encoding: utf8));
  for (var f in (fixtures['valid'] as List<dynamic>)) {
    f['master']['network'] = f['network'];
    f['master']['children'] = f['children'];
    f['master']['comment'] = f['comment'];
    for (var fc in (f['children'] as List<dynamic>)) {
      fc['network'] = f['network'];
      validAll.add(fc);
    }
    validAll.add(f['master']);
    for (var ff in validAll) {
      group(ff['comment'] ?? ff['base58Priv'], () {
        setUp(() {});
        NetworkType? network = ff['network'] == 'litecoin' ? litecoin : null;
        var hdPrv = Bip32Keys.fromBase58(ff['base58Priv'], network: network);
        test('works for private key -> HD wallet', () {
          verify(hdPrv, true, ff, network);
        });

        var hdPub = Bip32Keys.fromBase58(ff['base58'], network: network);
        test('works for public key -> HD wallet', () {
          verify(hdPub, false, ff, network);
        });

        if (ff['seed'] != null) {
          var seed = HEX.decode(ff['seed']);
          var hdSeed =
              Bip32Keys.fromSeed(Uint8List.fromList(seed), network: network);
          test('works for seed -> HD wallet', () {
            verify(hdSeed, true, ff, network);
          });
        }
      });
    }
  }

  test('fromBase58 throws', () {
    for (var f in (fixtures['invalid']['fromBase58'] as List<dynamic>)) {
      NetworkType? network =
          f['network'] != null && f['network'] == 'litecoin' ? litecoin : null;
      Bip32Keys? hd;
      try {
        hd = Bip32Keys.fromBase58(f['string'], network: network);
      } catch (err) {
        expect((err as ArgumentError).message, f['exception']);
      } finally {
        expect(hd, null);
      }
    }
  });

  test('works for Private -> public (neutered)', () {
    final f = fixtures['valid'][1];
    final c = f['master']['children'][0];
    final master = Bip32Keys.fromBase58(f['master']['base58Priv'] as String);
    final child = master.derive(c['m']).neutered;
    expect(child.toBase58(), c['base58']);
  });

  test('works for Private -> public (neutered, hardened)', () {
    final f = fixtures['valid'][0];
    final c = f['master']['children'][0];
    final master = Bip32Keys.fromBase58(f['master']['base58Priv'] as String);
    final child = master.deriveHardened(c['m']).neutered;
    expect(child.toBase58(), c['base58']);
  });

  test('works for Public -> public', () {
    final f = fixtures['valid'][1];
    final c = f['master']['children'][0];
    final master = Bip32Keys.fromBase58(f['master']['base58'] as String);
    final child = master.derive(c['m']);
    expect(child.toBase58(), c['base58']);
  });

  test('throws on Public -> public (hardened)', () {
    final f = fixtures['valid'][0];
    final c = f['master']['children'][0];
    final master = Bip32Keys.fromBase58(f['master']['base58'] as String);
    Bip32Keys? hd;
    try {
      hd = master.deriveHardened(c['m']);
    } catch (err) {
      expect((err as ArgumentError).message,
          "Missing private key for hardened child key");
    } finally {
      expect(hd, null);
    }
  });

  test('throws on wrong types', () {
    final f = fixtures['valid'][0];
    final master = Bip32Keys.fromBase58(f['master']['base58'] as String);
    for (var fx in (fixtures['invalid']['derive'] as List<dynamic>)) {
      Bip32Keys? hd;
      try {
        hd = master.derive(fx);
      } catch (err) {
        expect((err as ArgumentError).message, "Expected UInt32");
      } finally {
        expect(hd, null);
      }
    }
    for (var fx in (fixtures['invalid']['deriveHardened'] as List<dynamic>)) {
      Bip32Keys? hd;
      try {
        hd = master.deriveHardened(fx);
      } catch (err) {
        expect((err as ArgumentError).message, "Expected UInt31");
      } finally {
        expect(hd, null);
      }
    }
    for (var fx in (fixtures['invalid']['derivePath'] as List<dynamic>)) {
      Bip32Keys? hd;
      try {
        hd = master.derivePath(fx);
      } catch (err) {
        expect((err as ArgumentError).message, "Expected BIP32 Path");
      } finally {
        expect(hd, null);
      }
    }
    Bip32Keys? hdFPrv1, hdFPrv2;
    final zero32 = Uint8List.fromList(List.generate(32, (index) => 0));
    final one32 = Uint8List.fromList(List.generate(32, (index) => 1));
    try {
      hdFPrv1 = Bip32Keys.fromPrivateKey(Uint8List(2), one32);
    } catch (err) {
      expect((err as ArgumentError).message,
          "Expected property private of type Buffer(Length: 32)");
    } finally {
      expect(hdFPrv1, null);
    }
    try {
      hdFPrv2 = Bip32Keys.fromPrivateKey(zero32, one32);
    } catch (err) {
      expect((err as ArgumentError).message, "Private key not in range [1, n]");
    } finally {
      expect(hdFPrv2, null);
    }
  });

  test("works when private key has leading zeros", () {
    const key =
        "xprv9s21ZrQH143K3ckY9DgU79uMTJkQRLdbCCVDh81SnxTgPzLLGax6uHeBULTtaEtcAvKjXfT7ZWtHzKjTpujMkUd9dDb8msDeAfnJxrgAYhr";
    Bip32Keys hdkey = Bip32Keys.fromBase58(key);
    expect(HEX.encode(hdkey.private!),
        "00000055378cf5fafb56c711c674143f9b0ee82ab0ba2924f19b64f5ae7cdbfd");
    Bip32Keys child = hdkey.derivePath("m/44'/0'/0'/0/0'");
    expect(HEX.encode(child.private!),
        "3348069561d2a0fb925e74bf198762acc47dce7db27372257d2d959a9e6f8aeb");
  });

  test('derive', () {
    final hd = Bip32Keys.fromBase58(
        'xprv9s21ZrQH143K3Jpuz63XbuGs9CH9xG4sniVBBRVm6AJR57D9arxWz6FkXF3JSxSK7jUmVA11AdWa6ZsUtwGztE4QT5i8Y457RRPvMCc39rY');
    final d = hd.derivePath("m/1'/199007533'/627785449'/1521366139'/1'");
    expect(d.toBase58(),
        'xprvA39a1i4ieYqGUQ7G1KGnaGzGwm7v3emjms3QN4jZ3HPeubXjshA3XjD5XFaiNgWFvoyC2NV5jN4eFcsVhkrWkvwR4qjdPbue3kpt6Ur3JRf');
  });

  test("fromSeed", () {
    for (var f in (fixtures['invalid']['fromSeed'] as List<dynamic>)) {
      Bip32Keys? hd;
      try {
        hd = Bip32Keys.fromSeed(HEX.decode(f['seed']) as Uint8List);
      } catch (err) {
        expect((err as ArgumentError).message, f['exception']);
      } finally {
        expect(hd, null);
      }
    }
  });

  test("ecdsa", () {
    Uint8List seed = Uint8List.fromList(List.generate(32, (index) => 1));
    Uint8List hash = Uint8List.fromList(List.generate(32, (index) => 2));
    String sigStr =
        "9636ee2fac31b795a308856b821ebe297dda7b28220fb46ea1fbbd7285977cc04c82b734956246a0f15a9698f03f546d8d96fe006c8e7bd2256ca7c8229e6f5c";
    Uint8List signature = HEX.decode(sigStr) as Uint8List;
    Bip32Keys node = Bip32Keys.fromSeed(seed);
    expect(HEX.encode(node.sign(hash)), sigStr);
    expect(node.verify(hash, signature), true);
    expect(node.verify(seed, signature), false);
  });
}

void verify(Bip32Keys hd, prv, f, network) {
  expect(HEX.encode(hd.chainCode), f['chainCode']);
  expect(hd.depth, f['depth'] ?? 0);
  expect(hd.index, f['index'] ?? 0);
  expect(HEX.encode(hd.fingerprint), f['fingerprint']);
  expect(HEX.encode(hd.identifier), f['identifier']);
  expect(HEX.encode(hd.public), f['pubKey']);
  if (prv) {
    expect(hd.toBase58(), f['base58Priv']);
    expect(HEX.encode(hd.private!), f['privKey']);
    expect(hd.toWIF(), f['wif']);
  } else {
    expect(hd.private, null);
  }
  expect(hd.neutered.toBase58(), f['base58']);
  expect(hd.isNeutered, !prv);

  if (f['children'] == null) return;
  if (!prv &&
      (f['children'] as List<dynamic>)
          .map((fc) => fc['hardened'])
          .contains(true)) {
    return;
  }

  for (var cf in (f['children'] as List<dynamic>)) {
    var chd = hd.derivePath(cf['path']);
    verify(chd, prv, cf, network);
    var chdNoM = hd.derivePath((cf['path'] as String).substring(2)); // no m/
    verify(chdNoM, prv, cf, network);
  }

  // test deriving path from successive children
  var shd = hd;
  for (var cf in (f['children'] as List<dynamic>)) {
    if (cf['m'] == null) continue;
    if (cf['hardened'] != null && cf['hardened'] as bool) {
      shd = shd.deriveHardened(cf['m']);
    } else {
      // verify any publicly derived children
      if (cf['base58'] != null) {
        verify(shd.neutered.derive(cf['m']), false, cf, network);
      }
      shd = shd.derive(cf['m']);
      verify(shd, prv, cf, network);
    }
  }
}

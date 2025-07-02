import 'package:test/test.dart';
import 'package:bip32_keys/bip32_keys.dart';

class TestValues {
  // XPUB
  static get xpub =>
      'xpub6DJwRncrB8eNrzUq8XxgjwCZsEeWP8FeqBJbJQZ8JfuDwLdAzyjhHiHJieNuar1wjQTyihhMWtaKGE4DUd8uBgtyrNJqF5drwbNVUqb83b7';
  static get xpubFingerprint => '2bcd33b0';
  // conversions to other formats
  static get xpubToYpub =>
      'ypub6Y9CjTHmKpBriHfwxtkJx2J53CnxKkF9kHpp5oT1ggH6zSSQFduFumwSjrLVakfs93anUBHuyYvs9WfnCKYuyvaaii1FpzTMDKS8sVJo82W';
  static get xpubToZpub =>
      'zpub6ryU37xgUVjLZas4oFXwA7PaDAwQGNEefQM2sCLu4gez3YFdWJ4pXqbam4J5afKnYghbDetUSDHR2oHLv1xvnAGBb3hgQuGqV3VnG2rvas6';
  static get xpubToTpub =>
      'tpubDDgZx2SXtQbq8nfgaiwmwrXwCMkANWkiNottexcGeaf7gdHt5CanS9x8xgTh7LyBXJztLHDE3zQMxQYpsUz958MGuy48vcJ6XYxuEuPJAHp';
  static get xpubToUpub =>
      'upub5Ep9Wnc6j61wK6uUdTbp7fv4MLDAZGHA5qjvxDsUAeman3BVF1F1RXJtf2W9b84BWV7ZUGug8uWfcNDXKXtrnyrBFMDZVMBQ8RBZK5eWL4r';
  static get xpubToVpub =>
      'vpub5ZeQpTH1smZRAQ6bTpPSKm1ZXJMcVtGezxG9jcmMYf9Tq8ziVfQa3ay2gETjb2i6v8ENDkWEbZsDVeq63EJsbDXn7guz5FztQ9FChkr8jdA';

  // YPUB
  static get ypub =>
      'ypub6XepkBPvLjJ2P2XHVUEoYfYBUaHwg39ESnmxbs6UFHwk6rRAjanUahAm6cnmEBRytL2bvE7BZ7XpyDz9DP86yaReJNRD3KfVdCQM5YZ6LEs';
  static get ypubToXpub =>
      'xpub6CpZSWj1C3kYXjLAf7TBLaSgJc9VjR9jXgFjpUCasHZs3kbwUvcuxdWd5QqBEGn4UguoAkWd6TBH5wNaVgi6BLk3S2inTQr1MULhgxnrxKW';
  static get ypubFingerprint => 'ecd6654c';

// ZPUB
  static get zpub =>
      'zpub6ro6vd6Cn6apSQsrXVTE8d6UkygMYj1eAoXW9yUwbE2c1sfSQw2sEMyA4gGtxMpHv64NkoJdSYR7aEnJgUNNoQw7QZnys1vZ1qefVwPVc8T';
  static get zpubToXpub =>
      'xpub6D8aKHkNUjVrjpVcrmsyiSuUR3PTfV2eLaV4bBhAqDGqug2yuchjzEet2GMixYWT6opmFr7WXDi1ofZBF5YMCwZuftQ8hCHaUPXNiqfJvLs';
  static get zpubFingerprint => 'f6c41dd4';
}

void main() {
  group('SLIP-132 Tests', () {
    group('parse and tryParse functions', () {
      test('parse xpub format', () {
        final result = Slip132Format.parse(TestValues.xpub);
        expect(result, Slip132Format.xpub);
      });

      test('parse ypub format', () {
        final result = Slip132Format.parse(TestValues.ypub);
        expect(result, Slip132Format.ypub);
      });

      test('parse zpub format', () {
        final result = Slip132Format.parse(TestValues.zpub);
        expect(result, Slip132Format.zpub);
      });

      test('parse tpub format', () {
        final result = Slip132Format.parse(TestValues.xpubToTpub);
        expect(result, Slip132Format.tpub);
      });

      test('parse upub format', () {
        final result = Slip132Format.parse(TestValues.xpubToUpub);
        expect(result, Slip132Format.upub);
      });

      test('parse vpub format', () {
        final result = Slip132Format.parse(TestValues.xpubToVpub);
        expect(result, Slip132Format.vpub);
      });

      test('parse throws FormatException for invalid format', () {
        expect(() => Slip132Format.parse('invalid'), throwsA(anything));
      });

      test('parse throws FormatException for short input', () {
        expect(() => Slip132Format.parse('abc'), throwsA(anything));
      });
    });

    test('xpub fingerprint', () {
      final result = getFingerprint(TestValues.xpub, Slip132Format.xpub);
      expect(result, TestValues.xpubFingerprint);
    });

    test('ypub to xpub conversion', () {
      final result = changeVersionBytes(TestValues.ypub, Slip132Format.xpub);
      expect(result, TestValues.ypubToXpub);
    });

    test('ypub fingerprint', () {
      final result = getFingerprint(TestValues.ypub, Slip132Format.ypub);
      expect(result, TestValues.ypubFingerprint);
    });

    test('zpub to xpub conversion', () {
      final result = changeVersionBytes(TestValues.zpub, Slip132Format.xpub);
      expect(result, TestValues.zpubToXpub);
    });

    test('zpub fingerprint', () {
      final result = getFingerprint(TestValues.zpub, Slip132Format.zpub);
      expect(result, TestValues.zpubFingerprint);
    });

    test('xpub to ypub conversion', () {
      final result = changeVersionBytes(TestValues.xpub, Slip132Format.ypub);
      expect(result, TestValues.xpubToYpub);
    });

    test('xpub to zpub conversion', () {
      final result = changeVersionBytes(TestValues.xpub, Slip132Format.zpub);
      expect(result, TestValues.xpubToZpub);
    });

    test('xpub to tpub conversion', () {
      final result = changeVersionBytes(TestValues.xpub, Slip132Format.tpub);
      expect(result, TestValues.xpubToTpub);
    });

    test('xpub to upub conversion', () {
      final result = changeVersionBytes(TestValues.xpub, Slip132Format.upub);
      expect(result, TestValues.xpubToUpub);
    });

    test('xpub to vpub conversion', () {
      final result = changeVersionBytes(TestValues.xpub, Slip132Format.vpub);
      expect(result, TestValues.xpubToVpub);
    });
  });
}

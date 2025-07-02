import 'package:test/test.dart';
import 'package:bip32_keys/bip32_keys.dart';

class TestValues {
  static get xpub =>
      'xpub6DJwRncrB8eNrzUq8XxgjwCZsEeWP8FeqBJbJQZ8JfuDwLdAzyjhHiHJieNuar1wjQTyihhMWtaKGE4DUd8uBgtyrNJqF5drwbNVUqb83b7';
  static get xpubFingerprint => '2bcd33b0';
  static get ypub =>
      'ypub6XepkBPvLjJ2P2XHVUEoYfYBUaHwg39ESnmxbs6UFHwk6rRAjanUahAm6cnmEBRytL2bvE7BZ7XpyDz9DP86yaReJNRD3KfVdCQM5YZ6LEs';
  static get ypubToXpub =>
      'xpub6CpZSWj1C3kYXjLAf7TBLaSgJc9VjR9jXgFjpUCasHZs3kbwUvcuxdWd5QqBEGn4UguoAkWd6TBH5wNaVgi6BLk3S2inTQr1MULhgxnrxKW';
  static get ypubFingerprint => 'ecd6654c';
  static get zpub =>
      'zpub6ro6vd6Cn6apSQsrXVTE8d6UkygMYj1eAoXW9yUwbE2c1sfSQw2sEMyA4gGtxMpHv64NkoJdSYR7aEnJgUNNoQw7QZnys1vZ1qefVwPVc8T';
  static get zpubToXpub =>
      'xpub6D8aKHkNUjVrjpVcrmsyiSuUR3PTfV2eLaV4bBhAqDGqug2yuchjzEet2GMixYWT6opmFr7WXDi1ofZBF5YMCwZuftQ8hCHaUPXNiqfJvLs';
  static get zpubFingerprint => 'f6c41dd4';
}

void main() {
  group('SLIP-132 Tests', () {
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
  });
}

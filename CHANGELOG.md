## 3.1.0

- **FEAT**: Add SLIP-132 support with comprehensive enum-based format system
- **FEAT**: Add `Slip132Format` enum with all Bitcoin mainnet and testnet formats (xpub, ypub, zpub, etc.)
- **FEAT**: Add `Slip132Extension` on `Bip32Keys` with conversion and fingerprint methods
- **FEAT**: Add `changeVersionBytes()` function for converting between SLIP-132 formats
- **FEAT**: Add `getFingerprint()`, `getParentFingerprint()`, and `getDepth()` functions
- **FEAT**: Add comprehensive unit tests for SLIP-132 functionality
- **FEAT**: Update example to demonstrate SLIP-132 usage with enum-based API
- **FEAT**: Update README with SLIP-132 documentation and API reference
- **REFACTOR**: Move SLIP-132 functionality to extension for better separation of concerns
- **REFACTOR**: Remove NetworkConfig class and maps in favor of enum-based approach

## 3.0.1
- Downgrade `pointycastle` to `3.9.1` to ensure compatibility with other dependencies

## 3.0.0

- **BREAKING**: Rename BIP32 to Bip32Keys and library to bip32_keys
- **BREAKING**: Update Bip32Keys methods to use named parameters for network
- **BREAKING**: Update neutered and isNeutered methods to use getters
- **BREAKING**: Refactor and simplify error handling and improve code readability
- **BREAKING**: Split constants and enums into separate files
- **BREAKING**: Update analysis options and bump dependencies
- Add GitHub Actions workflow for tests and coverage
- Add bypassVersion parameter support to BIP32 factory methods
- Update README to include code coverage badge and fork information
- Fix linter issues

## 2.0.0
- Add null-safety

## 1.0.0

- Initial version, created by anicdh

## 1.0.1

- Format code & add description

## 1.0.2

- Change version bs58check

## 1.0.3

- Change generate BIP32 from function to factory

## 1.0.4

- Fix error message when generate BIP32 from private key
- Fix argument of wif decode function

## 1.0.5

- Fix wif decodeRaw function

## 1.0.6

- Fix derive bug

## 1.0.8

- Update pointycastle version to 2.0.0

## 1.0.10

- Fix sign
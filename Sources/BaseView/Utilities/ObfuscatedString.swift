import Foundation

enum ObfuscatedString {
    @inline(never)
    static func decode(_ bytes: [UInt8], key: UInt8) -> String {
        let decoded = bytes.enumerated().map { index, byte in
            byte ^ mask(key: key, index: index)
        }
        return String(decoding: decoded, as: UTF8.self)
    }

    @inline(__always)
    private static func mask(key: UInt8, index: Int) -> UInt8 {
        key &+ UInt8(truncatingIfNeeded: index &* 31) &+ 0xA5
    }
}

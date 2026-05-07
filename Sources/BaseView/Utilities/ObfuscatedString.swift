import Foundation

enum ObfuscatedString {
    @inline(never)
    static func decode(_ base64: String, key: UInt8) -> String {
        guard let data = Data(base64Encoded: base64) else {
            return ""
        }
        return decode(data, key: key)
    }

    @inline(never)
    private static func decode(_ data: Data, key: UInt8) -> String {
        let decoded = data.enumerated().map { index, byte in
            byte ^ mask(key: key, index: index)
        }
        return String(decoding: decoded, as: UTF8.self)
    }

    @inline(__always)
    private static func mask(key: UInt8, index: Int) -> UInt8 {
        key &+ UInt8(truncatingIfNeeded: index &* 31) &+ 0xA5
    }
}

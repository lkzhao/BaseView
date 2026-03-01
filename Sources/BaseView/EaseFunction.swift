import CoreGraphics

public struct EaseFunction {
    private let evaluator: (CGFloat) -> CGFloat
    public let isLinear: Bool

    public init(isLinear: Bool = false, _ evaluator: @escaping (CGFloat) -> CGFloat) {
        self.isLinear = isLinear
        self.evaluator = evaluator
    }

    public func value(at t: CGFloat) -> CGFloat {
        evaluator(t)
    }

    public static let linear = EaseFunction(isLinear: true) { $0 }
    public static let easeIn = EaseFunction { $0 * $0 }
    public static let easeOut = EaseFunction { t in
        let inverted = 1 - t
        return 1 - inverted * inverted
    }
    public static let easeInOut = EaseFunction { t in
        if t < 0.5 {
            return 2 * t * t
        }
        let inverted = -2 * t + 2
        return 1 - (inverted * inverted) / 2
    }
}

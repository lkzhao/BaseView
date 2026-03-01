import CoreGraphics

public enum EaseFunction: Equatable {
    case linear

    // Quadratic
    case easeIn
    case easeOut
    case easeInOut

    // Cubic
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic

    // Quartic
    case easeInQuart
    case easeOutQuart
    case easeInOutQuart

    // Quintic
    case easeInQuint
    case easeOutQuint
    case easeInOutQuint

    // Trigonometric
    case easeInSine
    case easeOutSine
    case easeInOutSine

    // Exponential
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo

    // Circular
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc

    public var isLinear: Bool {
        self == .linear
    }

    public func value(at t: CGFloat) -> CGFloat {
        switch self {
        case .linear:
            return t

        case .easeIn:
            return t * t
        case .easeOut:
            let inverted = 1 - t
            return 1 - inverted * inverted
        case .easeInOut:
            if t < 0.5 {
                return 2 * t * t
            }
            let inverted = -2 * t + 2
            return 1 - (inverted * inverted) / 2

        case .easeInCubic:
            return t * t * t
        case .easeOutCubic:
            let inverted = 1 - t
            return 1 - (inverted * inverted * inverted)
        case .easeInOutCubic:
            if t < 0.5 {
                return 4 * t * t * t
            }
            let inverted = -2 * t + 2
            return 1 - (inverted * inverted * inverted) / 2

        case .easeInQuart:
            return t * t * t * t
        case .easeOutQuart:
            let inverted = 1 - t
            return 1 - (inverted * inverted * inverted * inverted)
        case .easeInOutQuart:
            if t < 0.5 {
                return 8 * t * t * t * t
            }
            let inverted = -2 * t + 2
            return 1 - (inverted * inverted * inverted * inverted) / 2

        case .easeInQuint:
            return t * t * t * t * t
        case .easeOutQuint:
            let inverted = 1 - t
            return 1 - (inverted * inverted * inverted * inverted * inverted)
        case .easeInOutQuint:
            if t < 0.5 {
                return 16 * t * t * t * t * t
            }
            let inverted = -2 * t + 2
            return 1 - (inverted * inverted * inverted * inverted * inverted) / 2

        case .easeInSine:
            return 1 - cos((t * .pi) / 2)
        case .easeOutSine:
            return sin((t * .pi) / 2)
        case .easeInOutSine:
            return -(cos(.pi * t) - 1) / 2

        case .easeInExpo:
            if t == 0 {
                return 0
            }
            return pow(2, 10 * t - 10)
        case .easeOutExpo:
            if t == 1 {
                return 1
            }
            return 1 - pow(2, -10 * t)
        case .easeInOutExpo:
            if t == 0 {
                return 0
            }
            if t == 1 {
                return 1
            }
            if t < 0.5 {
                return pow(2, 20 * t - 10) / 2
            }
            return (2 - pow(2, -20 * t + 10)) / 2

        case .easeInCirc:
            return 1 - sqrt(1 - t * t)
        case .easeOutCirc:
            let shifted = t - 1
            return sqrt(1 - shifted * shifted)
        case .easeInOutCirc:
            if t < 0.5 {
                return (1 - sqrt(1 - 4 * t * t)) / 2
            }
            let shifted = -2 * t + 2
            return (sqrt(1 - shifted * shifted) + 1) / 2
        }
    }
}

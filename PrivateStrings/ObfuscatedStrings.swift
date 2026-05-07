enum ObfuscatedStringSource {
    enum BackdropView {
        static let backdropLayerClass = "CABackdropLayer"
        static let filterClass = "CAFilter"
        static let filterWithType = "filterWithType:"
        static let gaussianBlur = "gaussianBlur"
        static let colorMatrix = "colorMatrix"
        static let vibrantColorMatrix = "vibrantColorMatrix"
        static let displacementMap = "displacementMap"
        static let opacityPair = "opacityPair"
        static let inputRadius = "inputRadius"
        static let inputNormalizeEdges = "inputNormalizeEdges"
        static let inputColorMatrix = "inputColorMatrix"
        static let inputAmount = "inputAmount"
        static let enabled = "enabled"
        static let allowsInPlaceFiltering = "allowsInPlaceFiltering"
        static let scale = "scale"
        static let bleedAmount = "bleedAmount"
        static let marginWidth = "marginWidth"
        static let windowServerAware = "windowServerAware"
        static let ignoresScreenClip = "ignoresScreenClip"
        static let ignoresOffscreenGroups = "ignoresOffscreenGroups"
        static let reducesCaptureBitDepth = "reducesCaptureBitDepth"
        static let backdropRect = "backdropRect"
    }

    enum LensView {
        static let liquidLensClass = "_UILiquidLensView"
        static let style = "style"
        static let flexInteraction = "flexInteraction"
        static let restingBackgroundColor = "restingBackgroundColor"
        static let belowGlassWarpBackdrop = "belowGlassWarpBackdrop"
        static let lifted = "lifted"
        static let setLiftedAnimatedAlongsideCompletion = "setLifted:animated:alongside:completion:"
    }

    enum PortalView {
        static let portalClass = "_UIPortalView"
        static let sourceView = "sourceView"
        static let hidesSourceView = "hidesSourceView"
        static let matchesAlpha = "matchesAlpha"
        static let matchesTransform = "matchesTransform"
        static let matchesPosition = "matchesPosition"
        static let hidesSourceLayerInOtherPortals = "hidesSourceLayerInOtherPortals"
    }

    enum PrivateBlurEffectFactory {
        static let blurEffectClass = "_UICustomBlurEffect"
        static let effectWithBlurRadius = "effectWithBlurRadius:"
        static let effectWithVariableBlurRadiusImageMask = "effectWithVariableBlurRadius:imageMask:"
    }
}

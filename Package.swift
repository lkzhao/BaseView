// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BaseView",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "BaseView",
            targets: ["BaseView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lkzhao/BaseToolbox", from: "0.8.0"),
        .package(url: "https://github.com/p-x9/ObfuscateMacro.git", from: "0.14.0"),
        .package(url: "https://github.com/b3ll/Motion", from: "0.1.5"),
    ],
    targets: [
        .target(
            name: "BaseView",
            dependencies: ["BaseToolbox", "ObfuscateMacro", "Motion"])
    ]
)

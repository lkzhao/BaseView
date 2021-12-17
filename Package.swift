// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BaseView",
    platforms: [
        .iOS("13.4"),
    ],
    products: [
        .library(
            name: "BaseView",
            targets: ["BaseView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lkzhao/UIComponent", from: "0.10.1"),
        .package(url: "https://github.com/lkzhao/Hero2", from: "0.4.11"),
    ],
    targets: [
        .target(
            name: "BaseView",
            dependencies: ["Hero2", "UIComponent"])
    ]
)

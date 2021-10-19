// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZoomableImageView",
    platforms: [.iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "ZoomableImageView",
            targets: ["ZoomableImageView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ZoomableImageView",
            dependencies: []),
        .testTarget(
            name: "ZoomableImageViewTests",
            dependencies: ["ZoomableImageView"]),
    ],
    swiftLanguageVersions: [.v5]
)

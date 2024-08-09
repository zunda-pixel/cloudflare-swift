// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "CloudflareKit",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "ImagesClient",
      targets: [
        "ImagesClient"
      ]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types", from: "1.0.3"),
    .package(url: "https://github.com/vapor/multipart-kit", from: "4.7.0"),
    .package(url: "https://github.com/swiftlang/swift-testing", from: "0.11.0"),
  ],
  targets: [
    .target(
      name: "ImagesClient",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "MultipartKit", package: "multipart-kit"),
      ]
    ),
    .testTarget(
      name: "ImagesClientTests",
      dependencies: [
        .target(name: "ImagesClient"),
        .product(name: "Testing", package: "swift-testing"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)

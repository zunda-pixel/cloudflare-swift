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
        "ImagesClient",
      ]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types", from: "1.0.3"),
    .package(url: "https://github.com/davbeck/MultipartForm", from: "0.1.0"),
    .package(url: "https://github.com/apple/swift-format", from: "510.1.0"),
  ],
  targets: [
    .target(
      name: "ImagesClient",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "MultipartForm", package: "MultipartForm"),
      ]
    ),
    .testTarget(
      name: "ImagesClientTests",
      dependencies: [
        .target(name: "ImagesClient"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)

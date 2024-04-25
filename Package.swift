// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "CloudflareKit",
  defaultLocalization: "en",
  platforms: [.macOS(.v14)],
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

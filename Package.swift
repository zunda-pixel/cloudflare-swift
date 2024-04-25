// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "cloudflare-swift",
  defaultLocalization: "en",
  platforms: [.macOS(.v14)],
  products: [
    .library(
      name: "Images",
      targets: [
        "Images",
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
      name: "Images",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "MultipartForm", package: "MultipartForm"),
      ]
    ),
    .testTarget(
      name: "ImagesTests",
      dependencies: [
        .target(name: "Images"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)

// swift-tools-version: 6.0

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
      targets: ["ImagesClient"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types", from: "1.3.0"),
    .package(url: "https://github.com/vapor/multipart-kit", from: "4.7.0"),
    .package(url: "https://github.com/swiftlang/swift-testing", from: "0.11.0"),
    .package(url: "https://github.com/zunda-pixel/http-client", from: "0.1.3"),
  ],
  targets: [
    .target(
      name: "ImagesClient",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "MultipartKit", package: "multipart-kit"),
        .product(name: "HTTPClient", package: "http-client"),
      ]
    ),
    .testTarget(
      name: "ImagesClientTests",
      dependencies: [
        .target(name: "ImagesClient"),
        .product(name: "Testing", package: "swift-testing"),
        .product(name: "HTTPClientFoundation", package: "http-client"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)

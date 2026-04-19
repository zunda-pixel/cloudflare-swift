// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "cloudflare-swift",
  platforms: [
    .macOS(.v13),
    .iOS(.v15),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "CloudflareImages",
      targets: ["Images"]
    ),
    .library(
      name: "CloudflareEmailService",
      targets: ["EmailService"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types", from: "1.3.0"),
    .package(url: "https://github.com/vapor/multipart-kit", from: "5.0.0-alpha.5"),
    .package(url: "https://github.com/zunda-pixel/http-client", from: "0.3.0"),
  ],
  targets: [
    .target(
      name: "Images",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "MultipartKit", package: "multipart-kit"),
        .product(name: "HTTPClient", package: "http-client"),
      ]
    ),
    .testTarget(
      name: "ImagesTests",
      dependencies: [
        .target(name: "Images")
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "EmailService",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPClient", package: "http-client"),
      ]
    ),
    .testTarget(
      name: "EmailServiceTests",
      dependencies: [
        .target(name: "EmailService")
      ]
    ),
  ]
)

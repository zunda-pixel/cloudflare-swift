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
    .library(
      name: "RealtimeKit",
      targets: ["RealtimeKit"]
    )

  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.0"),
    .package(url: "https://github.com/vapor/multipart-kit.git", from: "5.0.0-alpha.5"),
    .package(url: "https://github.com/zunda-pixel/http-client.git", from: "0.3.0"),
    .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro.git", from: "0.5.2"),
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
    .target(
      name: "RealtimeKit",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "HTTPClient", package: "http-client"),
        .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro"),
      ]
    ),
    .testTarget(
      name: "RealtimeKitTests",
      dependencies: [
        .target(name: "RealtimeKit")
      ]
    ),
  ]
)

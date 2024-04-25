import HTTPTypes
import HTTPTypesFoundation
import XCTest

@testable import Images

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ImagesTests: XCTestCase {
  let client = ImageClient(
    apiToken: ProcessInfo.processInfo.environment["IMAGES_API_TOKEN"]!,
    accountId: ProcessInfo.processInfo.environment["ACCOUNT_ID"]!
  )

  let cloudflareLogoURL: URL = URL(
    string:
      "https://cf-assets.www.cloudflare.com/slt3lc6tev37/7bIgGp4hk4SFO0o3SBbOKJ/b48185dcf20c579960afad879b25ea11/CF_logo_stacked_blktype.jpg"
  )!
  var coudflareLogoName: String { cloudflareLogoURL.lastPathComponent }

  var samplePng: Data {
    let filePath = Bundle.module.url(forResource: "Swift_logo", withExtension: "svg")!
    return try! Data(contentsOf: filePath)
  }

  func testUploadData() async throws {
    let metadatas = ["test1": "test2"]
    let response = try await client.upload(
      imageData: samplePng,
      metadatas: metadatas
    )
    XCTAssertEqual(response.metadatas, metadatas)
    XCTAssertNil(response.fileName)
    XCTAssertEqual(response.requireSignedURLs, false)
    XCTAssertTrue(!response.variants.isEmpty)
  }

  func testUploadURL() async throws {
    let metadatas = ["test1": "test2"]
    let response = try await client.upload(
      imageURL: cloudflareLogoURL,
      metadatas: metadatas
    )
    XCTAssertEqual(response.metadatas, metadatas)
    XCTAssertEqual(response.fileName, coudflareLogoName)
    XCTAssertEqual(response.requireSignedURLs, false)
    XCTAssertTrue(!response.variants.isEmpty)
  }

  func testUploadDataWithId() async throws {
    let id = String(Int.random(in: Int.min..<Int.max))
    let response = try await client.upload(imageData: samplePng, id: id)
    XCTAssertEqual(id, response.id)
    XCTAssertEqual(response.metadatas, [:])
    XCTAssertNil(response.fileName)
    XCTAssertEqual(response.requireSignedURLs, false)
    XCTAssertTrue(!response.variants.isEmpty)
  }

  func testUploadURLWithId() async throws {
    let id = String(Int.random(in: Int.min..<Int.max))
    let response = try await client.upload(imageURL: cloudflareLogoURL, id: id)
    XCTAssertEqual(id, response.id)
    XCTAssertEqual(response.metadatas, [:])
    XCTAssertEqual(response.fileName, coudflareLogoName)
    XCTAssertEqual(response.requireSignedURLs, false)
    XCTAssertTrue(!response.variants.isEmpty)
  }

  func testUploadDataWithRequireSignedURLs() async throws {
    let response = try await client.upload(
      imageData: samplePng,
      requireSignedURLs: true
    )
    XCTAssertEqual(response.metadatas, [:])
    XCTAssertNil(response.fileName)
    XCTAssertEqual(response.requireSignedURLs, true)
    XCTAssertTrue(!response.variants.isEmpty)
  }

  func testUploadURLWithRequireSignedURLs() async throws {
    let response = try await client.upload(
      imageURL: cloudflareLogoURL,
      requireSignedURLs: true
    )
    XCTAssertEqual(response.metadatas, [:])
    XCTAssertEqual(response.fileName, coudflareLogoName)
    XCTAssertEqual(response.requireSignedURLs, true)
    XCTAssertTrue(!response.variants.isEmpty)
  }

  func testDeleteImage() async throws {
    let response = try await client.upload(imageURL: cloudflareLogoURL)
    try await client.delete(id: response.id)
  }

  func testFetchImages() async throws {
    let response1 = try await client.images(perPage: 10)
    XCTAssertEqual(response1.images.count, 10)
    let response2 = try await client.images(
      continuationToken: response1.continuationToken,
      perPage: 10
    )
    XCTAssertEqual(response2.images.count, 10)
  }

  func testFetchImage() async throws {
    let uploadedImage = try await client.upload(imageData: samplePng)
    let image = try await client.image(id: uploadedImage.id)
    // TODO need to fix Cloudflare Images API.
    // Upload Images's response uploaded date thas has one second more.
    // XCTAssertEqual(uploadedImage, image)
    XCTAssertEqual(image.id, uploadedImage.id)
    XCTAssertEqual(image.fileName, uploadedImage.fileName)
    XCTAssertEqual(image.metadatas, uploadedImage.metadatas)
    // XCTAssertEqual(image.uploadedDate, uploadedImage.uploadedDate)
    XCTAssertEqual(image.requireSignedURLs, uploadedImage.requireSignedURLs)
    XCTAssertEqual(image.variants, uploadedImage.variants)
  }

  func testUpdateImage() async throws {
    let metadatas = ["key1": "value1"]
    let requireSignedURLs = true

    let uploadedImage = try await client.upload(imageData: samplePng, requireSignedURLs: false)
    let image = try await client.update(
      id: uploadedImage.id,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )

    XCTAssertEqual(image.metadatas, metadatas)
    XCTAssertEqual(image.requireSignedURLs, requireSignedURLs)
  }

  func testUsageStats() async throws {
    let (allowedImageCount, currentImageCount) = try await client.usageStats()
    XCTAssertTrue(allowedImageCount > 0)
    XCTAssertTrue(currentImageCount > 0)
  }

  func testBaseImage() async throws {
    let uploadedImage = try await client.upload(imageData: samplePng, requireSignedURLs: false)
    _ = try await client.baseImage(id: uploadedImage.id)
  }

  func testCreateAuthenticatedUploadURLWithURL() async throws {
    let metadatas = ["key1": "value1"]
    let requireSignedURLs = true
    let (id, uploadURL) = try await client.createAuthenticatedUploadURL(
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
    let result = try await ImageClient.upload(uploadURL: uploadURL, imageURL: cloudflareLogoURL)
    XCTAssertEqual(result.id, id)
    XCTAssertEqual(result.metadatas, metadatas)
    XCTAssertEqual(result.requireSignedURLs, requireSignedURLs)
  }

  func testCreateAuthenticatedUploadURLWithData() async throws {
    let metadatas = ["key1": "value1"]
    let requireSignedURLs = true
    let (id, uploadURL) = try await client.createAuthenticatedUploadURL(
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
    let result = try await ImageClient.upload(uploadURL: uploadURL, imageData: samplePng)
    XCTAssertEqual(result.id, id)
    XCTAssertEqual(result.metadatas, metadatas)
    XCTAssertEqual(result.requireSignedURLs, requireSignedURLs)
  }
}

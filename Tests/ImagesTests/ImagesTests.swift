import XCTest
@testable import Images

final class ImagesTests: XCTestCase {
  let client = ImageClient(
    token: ProcessInfo.processInfo.environment["token"]!,
    accountId: ProcessInfo.processInfo.environment["accountId"]!
  )
  
  let cloudflareLogoURL: URL = URL(string: "https://cf-assets.www.cloudflare.com/slt3lc6tev37/7bIgGp4hk4SFO0o3SBbOKJ/b48185dcf20c579960afad879b25ea11/CF_logo_stacked_blktype.jpg")!
  var coudflareLogoName: String { cloudflareLogoURL.lastPathComponent }

  var samplePng: Data {
    let nsImage = NSImage(systemSymbolName: "house", accessibilityDescription: nil)!
    let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let rep = NSBitmapImageRep(cgImage: cgImage)
    let data = rep.representation(using: .png, properties: [:])!
    return data
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
      url: cloudflareLogoURL,
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
    let response = try await client.upload(url: cloudflareLogoURL, id: id)
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
      url: cloudflareLogoURL,
      requireSignedURLs: true
    )
    XCTAssertEqual(response.metadatas, [:])
    XCTAssertEqual(response.fileName, coudflareLogoName)
    XCTAssertEqual(response.requireSignedURLs, true)
    XCTAssertTrue(!response.variants.isEmpty)
  }
  
  func testDeleteImage() async throws {
    let response = try await client.upload(url: cloudflareLogoURL)
    try await client.delete(id: response.id)
  }
  
  func testFetchImages() async throws {
    let response1 = try await client.images(perPage: 10)
    XCTAssertEqual(response1.images.count, 10)
    let response2 = try await client.images(continuationToken: response1.continuationToken, perPage: 10)
    XCTAssertEqual(response2.images.count,  10)
  }
}

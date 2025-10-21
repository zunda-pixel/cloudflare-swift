import Foundation
import HTTPTypes
import HTTPTypesFoundation
import ImagesClient
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct ImagesClientTests {
  let client = ImagesClient(
    apiToken: ProcessInfo.processInfo.environment["IMAGES_API_TOKEN"]!,
    accountId: ProcessInfo.processInfo.environment["ACCOUNT_ID"]!,
    httpClient: .urlSession(.shared)
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

  @Test
  func uploadData() async throws {
    let metadatas = ["test1": "test2"]
    let response = try await client.upload(
      imageData: samplePng,
      metadatas: metadatas
    )
    #expect(response.metadatas == metadatas)
    #expect(response.fileName == nil)
    #expect(response.requireSignedURLs == false)
    #expect(response.variants.isEmpty == false)
  }

  @Test
  func uploadURL() async throws {
    let metadatas = ["test1": "test2"]
    let response = try await client.upload(
      imageURL: cloudflareLogoURL,
      metadatas: metadatas
    )
    #expect(response.metadatas == metadatas)
    #expect(response.fileName == coudflareLogoName)
    #expect(response.requireSignedURLs == false)
    #expect(response.variants.isEmpty == false)
  }

  @Test
  func uploadDataWithId() async throws {
    let id = String(Int.random(in: Int.min..<Int.max))
    let response = try await client.upload(imageData: samplePng, id: id)
    #expect(id == response.id)
    #expect(response.metadatas == [:])
    #expect(response.fileName == nil)
    #expect(response.requireSignedURLs == false)
    #expect(response.variants.isEmpty == false)
  }

  @Test
  func uploadURLWithId() async throws {
    let id = String(Int.random(in: Int.min..<Int.max))
    let response = try await client.upload(imageURL: cloudflareLogoURL, id: id)
    #expect(id == response.id)
    #expect(response.metadatas == [:])
    #expect(response.fileName == coudflareLogoName)
    #expect(response.requireSignedURLs == false)
    #expect(response.variants.isEmpty == false)
  }

  @Test
  func uploadDataWithRequireSignedURLs() async throws {
    let response = try await client.upload(
      imageData: samplePng,
      requireSignedURLs: true
    )
    #expect(response.metadatas == [:])
    #expect(response.fileName == nil)
    #expect(response.requireSignedURLs == true)
    #expect(response.variants.isEmpty == false)
  }

  @Test
  func uploadURLWithRequireSignedURLs() async throws {
    let response = try await client.upload(
      imageURL: cloudflareLogoURL,
      requireSignedURLs: true
    )
    #expect(response.metadatas == [:])
    #expect(response.fileName == coudflareLogoName)
    #expect(response.requireSignedURLs == true)
    #expect(response.variants.isEmpty == false)
  }

  @Test
  func deleteImage() async throws {
    let response = try await client.upload(imageURL: cloudflareLogoURL)
    try await client.delete(id: response.id)
  }

  func fetchImages() async throws {
    let response1 = try await client.images(perPage: 10)
    #expect(response1.images.count == 10)
    let response2 = try await client.images(
      continuationToken: response1.continuationToken,
      perPage: 10
    )
    #expect(response2.images.count == 10)
  }

  @Test
  func fetchImage() async throws {
    let uploadedImage = try await client.upload(imageData: samplePng)
    let image = try await client.image(id: uploadedImage.id)
    // TODO need to fix Cloudflare Images API.
    // Upload Images's response uploaded date thas has one second more.
    // #expect(uploadedImage == image)
    #expect(image.id == uploadedImage.id)
    #expect(image.fileName == uploadedImage.fileName)
    #expect(image.metadatas == uploadedImage.metadatas)
    // #expect(image.uploadedDate == uploadedImage.uploadedDate)
    #expect(image.requireSignedURLs == uploadedImage.requireSignedURLs)
    #expect(image.variants == uploadedImage.variants)
  }

  @Test
  func updateImage() async throws {
    let metadatas = ["key1": "value1"]
    let requireSignedURLs = true

    let uploadedImage = try await client.upload(imageData: samplePng, requireSignedURLs: false)
    let image = try await client.update(
      id: uploadedImage.id,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )

    #expect(image.metadatas == metadatas)
    #expect(image.requireSignedURLs == requireSignedURLs)
  }

  @Test
  func usageStats() async throws {
    let (allowedImageCount, currentImageCount) = try await client.usageStats()
    #expect(allowedImageCount > 0)
    #expect(currentImageCount > 0)
  }

  @Test
  func baseImage() async throws {
    let uploadedImage = try await client.upload(imageData: samplePng, requireSignedURLs: false)
    _ = try await client.baseImage(id: uploadedImage.id)
  }

  @Test
  func createAuthenticatedUploadURLWithURL() async throws {
    let metadatas = ["key1": "value1"]
    let requireSignedURLs = true
    let (id, uploadURL) = try await client.createAuthenticatedUploadURL(
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
    let result = try await ImagesClient.upload(
      uploadURL: uploadURL,
      imageURL: cloudflareLogoURL,
      httpClient: .urlSession(.shared)
    )
    #expect(result.id == id)
    #expect(result.metadatas == metadatas)
    #expect(result.requireSignedURLs == requireSignedURLs)
  }

  @Test
  func createAuthenticatedUploadURLWithData() async throws {
    let metadatas = ["key1": "value1"]
    let requireSignedURLs = true
    let (id, uploadURL) = try await client.createAuthenticatedUploadURL(
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
    let result = try await ImagesClient.upload(
      uploadURL: uploadURL,
      imageData: samplePng,
      httpClient: .urlSession(.shared)
    )
    #expect(result.id == id)
    #expect(result.metadatas == metadatas)
    #expect(result.requireSignedURLs == requireSignedURLs)
  }
}

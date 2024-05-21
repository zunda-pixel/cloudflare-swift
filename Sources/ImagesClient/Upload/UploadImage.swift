import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// Upload Image Data to Cloudflare Images
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-upload-an-image-via-url
  /// - Parameters:
  ///   - imageData: MultipartForm Image Data. Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  ///   - id: Image ID
  ///   - metadatas: Metadatas
  ///   - requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: ``ImageResponse.Result``
  private func upload(
    imageData: ImageBody,
    id imageId: String?,
    metadatas: [String: String],
    requireSignedURLs: Bool
  ) async throws -> Image {
    let url = URL(string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1")!
    let body = Body(
      id: imageId,
      imageData: imageData,
      metadata: metadatas,
      requireSignedURLs: requireSignedURLs
    )

    let boundary = UUID().uuidString

    let formData = try! FormDataEncoder().encode(body, boundary: boundary)

    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: HTTPFields([
        .init(name: .authorization, value: "Bearer \(apiToken)"),
        .init(name: .contentType, value: "multipart/form-data; boundary=\(boundary)"),
      ])
    )

    let (data, _) = try await URLSession.shared.upload(for: request, from: Data(formData.utf8))

    let response = try JSONDecoder.images.decode(ImagesResponse<Image>.self, from: data)

    if let result = response.result, response.success {
      return result
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }

  /// Upload Image Data to Cloudflare Images
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-upload-an-image-via-url
  /// - Parameters:
  ///   - imageData: Image Data. Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  ///   - id: Image ID
  ///   - metadatas: Metadatas
  ///   - requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: ``ImageResponse.Result``
  public func upload(
    imageData: Data,
    id imageId: String? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool = false
  ) async throws -> Image {
    return try await self.upload(
      imageData: .file(imageData),
      id: imageId,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }

  /// Upload Image Data from URL to Cloudflare Images
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-upload-an-image-via-url
  /// - Parameters:
  ///   - url: Image URL. Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  ///   - id: Image ID
  ///   - metadatas: Metadatas
  ///   - requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: ``ImageResponse.Result``
  public func upload(
    imageURL: URL,
    id imageId: String? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool = false
  ) async throws -> Image {
    return try await self.upload(
      imageData: .url(imageURL),
      id: imageId,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }
}

private struct Body: Encodable {
  var id: String?
  var imageData: ImageBody
  var metadata: [String: String]
  var requireSignedURLs: Bool

  private enum CodingKeys: CodingKey {
    case id
    case url
    case file
    case metadata
    case requireSignedURLs
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.id, forKey: .id)
    switch imageData {
    case .url(let url):
      try container.encode(url.absoluteString, forKey: .url)
    case .file(let imageData):
      try container.encode(imageData, forKey: .file)
    }
    let rawMetadata = String(decoding: try! JSONEncoder().encode(metadata), as: UTF8.self)
    try container.encode(rawMetadata, forKey: .metadata)
    try container.encode(self.requireSignedURLs, forKey: .requireSignedURLs)
  }
}

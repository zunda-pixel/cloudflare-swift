import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartForm

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
    imageData: MultipartForm.Part,
    id imageId: String?,
    metadatas: [String: String],
    requireSignedURLs: Bool
  ) async throws -> Image {
    let url = URL(string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1")!
    let metadatas = try! String(decoding: JSONEncoder().encode(metadatas), as: UTF8.self)
    var form = MultipartForm(parts: [
      imageData,
      MultipartForm.Part(name: "metadata", value: metadatas),
      MultipartForm.Part(name: "requireSignedURLs", value: requireSignedURLs.description),
    ])
    imageId.map { form.parts.append(.init(name: "id", value: $0)) }

    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: HTTPFields(
        dictionaryLiteral: (.authorization, "Bearer \(apiToken)"), (.contentType, form.contentType)
      )
    )

    let (data, _) = try await URLSession.shared.upload(for: request, from: form.bodyData)

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
      imageData: MultipartForm.Part(name: "file", data: imageData),
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
      imageData: MultipartForm.Part(name: "url", value: imageURL.absoluteString),
      id: imageId,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }
}

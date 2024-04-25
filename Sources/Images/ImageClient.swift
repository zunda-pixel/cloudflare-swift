import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartForm

public struct ImageClient {
  public let token: String
  public let accountId: String
  
  public init(
    token: String,
    accountId: String
  ) {
    self.token = token
    self.accountId = accountId
  }
  
  private func upload(
    imageData: MultipartForm.Part,
    id: String?,
    metadatas: [String: String],
    requireSignedURLs: Bool
  ) async throws -> ImagesResponse.Result {
    let url = URL(string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1")!
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: HTTPFields(dictionaryLiteral: (.authorization, "Bearer \(token)"), (.contentType, "multipart/form-data"))
    )

    let metadatas = try! String(decoding: JSONEncoder().encode(metadatas), as: UTF8.self)
    var form = MultipartForm(parts: [
      imageData,
      MultipartForm.Part(name: "metadata", value: metadatas),
      MultipartForm.Part(name: "requireSignedURLs", value: requireSignedURLs.description),
    ])
    id.map { form.parts.append(.init(name: "id", value: $0)) }

    var urlReqeust = URLRequest(httpRequest: request)!
    urlReqeust.setValue(form.contentType, forHTTPHeaderField: "Content-Type")

    let (data, _) = try await URLSession.shared.upload(for: urlReqeust, from: form.bodyData)
    
    let response = try JSONDecoder.images.decode(ImagesResponse.self, from: data)
    
    if response.success {
      return response.result!
    } else {
      throw handleError(errors: response.errors)
    }
  }
  
  /// Upload Image Data to Cloudflare Images
  /// - Parameters:
  ///   - imageData: Image Data. Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  ///   - id: Image ID
  ///   - metadatas: Metadatas
  ///   - requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: ``ImageResponse.Result``
  public func upload(
    imageData: Data,
    id: String? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool = false
  ) async throws -> ImagesResponse.Result {
    return try await self.upload(
      imageData: MultipartForm.Part(name: "file", data: imageData),
      id: id,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }
  
  // Upload Image Data from URL to Cloudflare Images
  /// - Parameters:
  ///   - url: Image URL. Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  ///   - id: Image ID
  ///   - metadatas: Metadatas
  ///   - requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: ``ImageResponse.Result``
  public func upload(
    url: URL,
    id: String? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool = false
  ) async throws -> ImagesResponse.Result {
    return try await self.upload(
      imageData: MultipartForm.Part(name: "url", value: url.absoluteString),
      id: id,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }
  
  private func handleError(errors: [MessageContent]) -> RequestError {
    if errors.map(\.code).contains(5410) {
      return RequestError.privateImageCantSetCustomID
    }
    if errors.map(\.code).contains(5411) {
      return RequestError.invalidCustomId
    }
    else if errors.map(\.code).contains(5455) {
      return RequestError.invalidContentType
    }
    else if let error = errors.first(where: { $0.code == 5454 }) {
      return RequestError.failedFetch(message: error.message)
    }
    else if let error = errors.first(where: { $0.code == 7003 }) {
      return RequestError.couldNotRoute(message: error.message)
    }
    else if errors.map(\.code).contains(10000) {
      return RequestError.invalidAuthentication
    }
    else {
      return RequestError.unknown(errors: errors)
    }
  }
}

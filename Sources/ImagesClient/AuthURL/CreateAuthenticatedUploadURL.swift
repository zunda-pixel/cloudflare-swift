import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// Create Authenticated Upload URL
  /// - Parameters:
  ///   - id: Image ID
  ///   - expiryDate: Expirly Date
  ///   - metadatas: Metadatas
  ///   - requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: (id: String, uploadURL: URL)
  public func createAuthenticatedUploadURL(
    id imageId: String? = nil,
    expiryDate: Date? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool? = nil
  ) async throws -> (id: String, uploadURL: URL) {
    let url = URL(
      string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v2/direct_upload"
    )!

    let boundary = UUID().uuidString

    let body = Body(
      metadata: metadatas,
      id: imageId,
      expiryDate: expiryDate,
      requireSignedURLs: requireSignedURLs
    )

    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: .init([
        .init(name: .authorization, value: "Bearer \(apiToken)"),
        .init(name: .contentType, value: "multipart/form-data; boundary=\(boundary)")
      ])
    )

    let bodyString = try! FormDataEncoder().encode(body, boundary: boundary)

    let (data, _) = try await URLSession.shared.upload(for: request, from: Data(bodyString.utf8))

    let response = try JSONDecoder.images.decode(
      ImagesResponse<AuthenticatedUploadURLResult>.self,
      from: data
    )
    if let result = response.result, response.success {
      return (result.id, result.uploadURL)
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

private struct AuthenticatedUploadURLResult: Sendable, Codable, Hashable {
  var id: String
  var uploadURL: URL
}

private struct AuthenticatedUploadURLBody: Sendable, Codable, Hashable {
  var id: String?
  var expiryDate: Date?
  var metadatas: [String: String]
  var requireSignedURLs: Bool?

  private enum CodingKeys: String, CodingKey {
    case expiryDate = "expiry"
    case id
    case metadatas = "metadata"
    case requireSignedURLs
  }
}

private struct Body: Encodable {
  var metadata: [String: String]
  var id: String?
  var expiryDate: Date?
  var requireSignedURLs: Bool?

  private enum CodingKeys: CodingKey {
    case metadata
    case id
    case expiryDate
    case requireSignedURLs
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let rawMetadata = String(decoding: try! JSONEncoder().encode(metadata), as: UTF8.self)
    try container.encode(rawMetadata, forKey: .metadata)
    try container.encodeIfPresent(self.id, forKey: .id)
    try container.encodeIfPresent(self.expiryDate, forKey: .expiryDate)
    try container.encodeIfPresent(self.requireSignedURLs, forKey: .requireSignedURLs)
  }
}

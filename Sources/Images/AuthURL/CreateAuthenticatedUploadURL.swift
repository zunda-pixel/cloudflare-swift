import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartForm

extension ImageClient {
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

    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: HTTPFields(dictionaryLiteral: (.authorization, "Bearer \(apiToken)"))
    )

    let metadatas = try! String(decoding: JSONEncoder().encode(metadatas), as: UTF8.self)
    var form = MultipartForm(parts: [
      MultipartForm.Part(name: "metadata", value: metadatas)
    ])
    imageId.map { form.parts.append(.init(name: "id", value: $0)) }
    expiryDate.map {
      form.parts.append(.init(name: "expiry", value: ISO8601DateFormatter().string(from: $0)))
    }
    requireSignedURLs.map {
      form.parts.append(.init(name: "requireSignedURLs", value: $0.description))
    }

    var urlRequest = URLRequest(httpRequest: request)!
    urlRequest.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
    urlRequest.httpBody = form.bodyData

    let (data, _) = try await URLSession.shared.data(for: urlRequest)

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

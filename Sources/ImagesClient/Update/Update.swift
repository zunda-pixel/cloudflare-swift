import Foundation
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImageClient {
  /// Update Image
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-update-image
  /// - Parameter imageId: Image ID
  /// - Parameter metadatas: Metadatas
  /// - Parameter requireSignedURLs: Set to True for making the image private. If Set to True, Dont set Custom Image ID
  /// - Returns: ``Image``
  public func update(
    id imageId: String, metadatas: [String: String] = [:], requireSignedURLs: Bool? = nil
  ) async throws -> Image {
    let url = URL(
      string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1/\(imageId)"
    )!

    let request = HTTPRequest(
      method: .patch,
      url: url,
      headerFields: HTTPFields(dictionaryLiteral: (.authorization, "Bearer \(apiToken)"))
    )

    let body = UpdateBody(metadatas: metadatas, requireSignedURLs: requireSignedURLs)
    let bodyData = try! JSONEncoder().encode(body)

    var urlRequest = URLRequest(httpRequest: request)!
    urlRequest.httpBody = bodyData

    let (data, _) = try await URLSession.shared.data(for: urlRequest)

    let response = try JSONDecoder.images.decode(ImagesResponse<Image>.self, from: data)
    if let result = response.result, response.success {
      return result
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

private struct UpdateBody: Sendable, Encodable, Hashable {
  var metadatas: [String: String]
  var requireSignedURLs: Bool?

  private enum CodingKeys: String, CodingKey {
    case metadatas = "metadata"
    case requireSignedURLs
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if !self.metadatas.isEmpty {
      try container.encode(self.metadatas, forKey: .metadatas)
    }

    try container.encodeIfPresent(requireSignedURLs, forKey: .requireSignedURLs)
  }
}

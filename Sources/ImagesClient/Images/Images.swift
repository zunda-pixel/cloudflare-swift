import Foundation
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// List Images
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-list-images-v2
  /// - Parameters:
  ///   - continuationToken: Continuation token for a next page. List images V2 returns continuation_token
  ///   - perPage: Number of items per page. 10 <= perPage <= 10000
  ///   - sorOrder: Sorting order by upload time.
  /// - Returns: ``ImageResult``
  public func images(
    continuationToken: String? = nil, perPage: Int = 1000, sorOrder: SortOrder = .desc
  ) async throws -> ImagesResult {
    let url = self.baseURL.appendingPathComponent("accounts/\(accountId)/images/v2")

    var queries: [String: String] = [
      "per_page": String(perPage),
      "sort_order": sorOrder.rawValue,
    ]

    continuationToken.map { queries["continuation_token"] = $0 }

    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    components.queryItems = queries.map { .init(name: $0.key, value: $0.value) }

    let request = HTTPRequest(
      method: .get,
      url: components.url!
    )

    let (data, _) = try await self.execute(request)

    let response = try JSONDecoder.images.decode(ImagesResponse<ImagesResult>.self, from: data)
    if let result = response.result, response.success {
      return result
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

public struct ImagesResult: Sendable, Codable, Hashable {
  public var images: [Image]
  public var continuationToken: String?

  private enum CodingKeys: String, CodingKey {
    case images
    case continuationToken = "continuation_token"
  }
}

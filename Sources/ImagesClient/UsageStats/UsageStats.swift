import Foundation
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// Images usage statistics
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-images-usage-statistics
  /// - Returns: (allowedImageCount: Int, currentImageCount: Int)
  public func usageStats() async throws -> (allowedImageCount: Int, currentImageCount: Int) {
    let url = self.baseURL.appendingPathComponent("accounts/\(accountId)/images/v1/stats")

    let request = HTTPRequest(
      method: .get,
      url: url
    )

    let (data, _) = try await self.execute(request)

    let response = try JSONDecoder.images.decode(ImagesResponse<ImageCount>.self, from: data)
    if let result = response.result, response.success {
      return (result.count.allowedImageCount, result.count.currentImageCount)
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

private struct ImageCount: Sendable, Codable, Hashable {
  var count: Result

  struct Result: Sendable, Codable, Hashable {
    var allowedImageCount: Int
    var currentImageCount: Int

    private enum CodingKeys: String, CodingKey {
      case allowedImageCount = "allowed"
      case currentImageCount = "current"
    }
  }
}

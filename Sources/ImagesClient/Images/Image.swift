import Foundation
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// Image
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-image-details
  /// - Parameter imageId: Image ID
  /// - Returns: ``Image``
  public func image(id imageId: String) async throws -> Image {
    let url = URL(
      string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1/\(imageId)"
    )!

    let request = HTTPRequest(
      method: .get,
      url: url
    )

    let (data, _) = try await self.execute(request)

    let response = try JSONDecoder.images.decode(ImagesResponse<Image>.self, from: data)
    if let result = response.result, response.success {
      return result
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

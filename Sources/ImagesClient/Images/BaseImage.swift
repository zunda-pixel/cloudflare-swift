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
  public func baseImage(id imageId: String) async throws -> Data {
    let url = self.baseURL.appendingPathComponent("accounts/\(accountId)/images/v1/\(imageId)/blob")

    let request = HTTPRequest(
      method: .get,
      url: url
    )

    let (data, response) = try await self.execute(request)

    if response.status.code == 200 {
      return data
    } else {
      let response = try JSONDecoder.images.decode(ImagesResponse<EmptyResult>.self, from: data)
      throw Self.handleError(errors: response.errors)
    }
  }
}

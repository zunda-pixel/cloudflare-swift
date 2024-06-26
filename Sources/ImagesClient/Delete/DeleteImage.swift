import Foundation
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// Delete Image
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-delete-image
  /// - Parameter imageId: Image ID
  public func delete(id imageId: String) async throws {
    let url = self.baseURL.appendingPathComponent("accounts/\(accountId)/images/v1/\(imageId)")

    let request = HTTPRequest(
      method: .delete,
      url: url
    )

    let (data, _) = try await self.execute(request)

    let response = try JSONDecoder().decode(ImagesResponse<EmptyResult>.self, from: data)
    if !response.success {
      throw RequestError.failedDelete
    }
  }
}

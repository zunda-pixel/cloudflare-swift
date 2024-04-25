import Foundation
import HTTPTypes
import HTTPTypesFoundation

extension ImageClient {
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
      url: url,
      headerFields: HTTPFields(dictionaryLiteral: (.authorization, "Bearer \(token)"))
    )

    let (data, _) = try await URLSession.shared.data(for: request)

    let response = try JSONDecoder.images.decode(ImagesResponse<Image>.self, from: data)
    if let result = response.result, response.success {
      return result
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

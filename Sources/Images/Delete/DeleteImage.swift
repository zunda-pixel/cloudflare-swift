import Foundation
import HTTPTypes
import HTTPTypesFoundation

extension ImageClient {
  /// Delete Image
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-delete-image
  /// - Parameter imageId: Image ID
  public func delete(id imageId: String) async throws {
    let url = URL(string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1/\(imageId)")!
    let request = HTTPRequest(
      method: .delete,
      url: url,
      headerFields: HTTPFields(dictionaryLiteral: (.authorization, "Bearer \(token)"))
    )
    
    let (data, _) = try await URLSession.shared.data(for: request)

    let response = try JSONDecoder().decode(ImagesResponse<DeleteResult>.self, from: data)
    if !response.success {
      throw RequestError.failedDelete
    }
  }
}

private struct DeleteResult: Sendable, Codable, Hashable {
  
}

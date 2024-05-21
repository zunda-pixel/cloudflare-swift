import Foundation
import HTTPTypes

public struct ImagesClient<HTTPClient: HTTPClientProtocol> {
  public let apiToken: String
  public let accountId: String
  public let httpClient: HTTPClient
  public var baseURL = URL(string: "https://api.cloudflare.com/client/v4")!

  public init(
    apiToken: String,
    accountId: String,
    httpClient: HTTPClient
  ) {
    self.apiToken = apiToken
    self.accountId = accountId
    self.httpClient = httpClient
  }

  func execute(_ request: HTTPRequest, body: Data? = nil) async throws -> (Data, HTTPResponse) {
    var request = request
    request.headerFields[.authorization] = "Bearer \(apiToken)"
    return try await httpClient.execute(request, body: body)
  }
}

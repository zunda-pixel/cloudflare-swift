import Foundation
import HTTPClient
import HTTPTypes
import MemberwiseInit

@MemberwiseInit(.public)
public struct Client<HTTPClient: HTTPClientProtocol & Sendable>: Sendable {
  public var accountId: String
  public var apiToken: String
  public var httpClient: HTTPClient
  public var baseURL: URL = URL(string: "https://api.cloudflare.com/client/v4")!

  func execute(_ request: HTTPRequest, body: Data? = nil) async throws -> (Data, HTTPResponse) {
    var request = request
    request.headerFields[.authorization] = "Bearer \(apiToken)"
    request.headerFields[.contentType] = "application/json"
    return try await httpClient.execute(for: request, from: body)
  }
}

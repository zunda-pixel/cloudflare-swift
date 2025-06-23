import Foundation
import HTTPClient
import HTTPTypes

public struct Client<HTTPClient: HTTPClientProtocol & Sendable>: Sendable {
  public var apiToken: String
  public var httpClient: HTTPClient
  public var baseURL = URL(string: "https://rtk.realtime.cloudflare.com/v2")!

  public init(
    apiToken: String,
    httpClient: HTTPClient
  ) {
    self.apiToken = apiToken
    self.httpClient = httpClient
  }
  
  public init(
    organizationId: String,
    apiKey: String,
    httpClient: HTTPClient
  ) {
    self.apiToken = Data("\(organizationId):\(apiKey)".utf8).base64EncodedString()
    self.httpClient = httpClient
  }

  func execute(_ request: HTTPRequest, body: Data? = nil) async throws -> (Data, HTTPResponse) {
    var request = request
    request.headerFields[.authorization] = "Basic \(apiToken)"
    request.headerFields[.accept] = "application/json"
    return try await httpClient.execute(for: request, from: body)
  }
}

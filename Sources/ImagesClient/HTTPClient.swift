import HTTPTypes
import Foundation

public protocol HTTPClientProtocol: Sendable {
  func execute(_ request: HTTPRequest, body: Data?) async throws -> (Data, HTTPResponse)
}

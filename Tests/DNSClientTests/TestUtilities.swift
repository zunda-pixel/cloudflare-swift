import Foundation
import HTTPClient
import HTTPTypes

// MARK: - Mock HTTP Client

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
  var mockResponse: (Data, HTTPResponse)?
  var lastRequest: HTTPRequest?
  var lastRequestBody: Data?

  func execute(for request: HTTPRequest, from body: Data?) async throws -> (Data, HTTPResponse) {
    lastRequest = request
    lastRequestBody = body

    guard let response = mockResponse else {
      throw NSError(
        domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock response set"])
    }

    return response
  }
}

// MARK: - Test Response Helpers

extension MockHTTPClient {
  static func createSuccessResponse<T: Codable>(_ result: T) -> Data {
    let response: [String: Any] = [
      "success": true,
      "errors": [],
      "messages": [],
      "result": try! JSONSerialization.jsonObject(with: JSONEncoder().encode(result)),
    ]

    return try! JSONSerialization.data(withJSONObject: response)
  }

  static func createSuccessResponse(dictionary: [String: Any]) -> Data {
    let response: [String: Any] = [
      "success": true,
      "errors": [],
      "messages": [],
      "result": dictionary,
    ]

    return try! JSONSerialization.data(withJSONObject: response)
  }

  static func createErrorResponse(errors: [[String: Any]]) -> Data {
    let response: [String: Any] = [
      "success": false,
      "errors": errors,
      "messages": [],
      "result": NSNull(),
    ]

    return try! JSONSerialization.data(withJSONObject: response)
  }
}

import Foundation
import HTTPClient
import HTTPTypes
import Images
import Testing

private struct StubHTTPClient: HTTPClientProtocol {
  func execute(for request: HTTPRequest, from body: Data?) async throws -> (Data, HTTPResponse) {
    #expect(request.method == .get)
    #expect(request.path == "/client/v4/accounts/test-account/images/v1/stats")
    #expect(request.headerFields[.authorization] == "Bearer test-token")
    #expect(body == nil)

    let response = """
      {"success":true,"errors":[],"messages":[],"result":{"count":{"allowed":100,"current":42}}}
      """
    return (Data(response.utf8), HTTPResponse(status: .ok))
  }
}

@Suite
struct OfflineTests {
  @Test
  func imageUsageStats() async throws {
    let client = Client(
      accountId: "test-account", apiToken: "test-token", httpClient: StubHTTPClient()
    )

    let stats = try await client.usageStats()

    #expect(stats.allowedImageCount == 100)
    #expect(stats.currentImageCount == 42)
  }
}

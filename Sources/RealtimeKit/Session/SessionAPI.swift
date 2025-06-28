import Foundation
import HTTPTypes

extension Client {
  public func sessions() async throws -> [Session] {
    let url = baseURL.appendingPathComponent("sessions")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(PagableResponse<SessionResponse>.self, from: data)
    return response.data.sessions
  }
}

private struct SessionResponse: Decodable {
  var sessions: [Session]
}

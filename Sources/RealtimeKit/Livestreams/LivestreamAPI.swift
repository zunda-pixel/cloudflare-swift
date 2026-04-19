import Foundation
import HTTPTypes

extension Client {
  /// Create a new livestream.
  @discardableResult
  public func createLivestream(_ livestream: NewLivestream) async throws -> Livestream {
    let url = baseURL.appendingPathComponent("livestreams")
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(livestream)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Livestream>.self, from: data)
    return response.data
  }

  /// Get details of a specific livestream.
  public func livestream(for livestreamId: Livestream.ID) async throws -> Livestream {
    let url = baseURL.appendingPathComponent("livestreams/\(livestreamId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Livestream>.self, from: data)
    return response.data
  }

  /// Get all livestreams.
  public func livestreams() async throws -> PagableResponse<[Livestream]> {
    let url = baseURL.appendingPathComponent("livestreams")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(PagableResponse<[Livestream]>.self, from: data)
    return response
  }

  /// Start a livestream for a meeting.
  @discardableResult
  public func startLivestream(for meetingId: Meeting.ID) async throws -> Livestream {
    let url = baseURL.appendingPathComponent("livestreams")
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let body = ["meeting_id": meetingId.uuidString]
    let bodyData = try JSONEncoder().encode(body)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Livestream>.self, from: data)
    return response.data
  }

  /// Update a livestream (start/stop).
  @discardableResult
  public func updateLivestream(
    for livestreamId: Livestream.ID,
    action: LivestreamAction
  ) async throws -> Livestream {
    let url = baseURL.appendingPathComponent("livestreams/\(livestreamId)")
    let request = HTTPRequest(
      method: .put,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(action)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Livestream>.self, from: data)
    return response.data
  }
}

public struct LivestreamAction: Encodable, Sendable {
  public var action: Action

  public enum Action: String, Encodable, Sendable {
    case start
    case stop
  }

  public static let start = LivestreamAction(action: .start)
  public static let stop = LivestreamAction(action: .stop)
}

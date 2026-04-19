import Foundation
import HTTPTypes

extension Client {
  /// Start a recording for a meeting.
  @discardableResult
  public func startRecording(_ startRecording: StartRecording) async throws -> Recording {
    let url = baseURL.appendingPathComponent("recordings")
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(startRecording)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Recording>.self, from: data)
    return response.data
  }

  /// Get details of a specific recording.
  public func recording(for recordingId: Recording.ID) async throws -> Recording {
    let url = baseURL.appendingPathComponent("recordings/\(recordingId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Recording>.self, from: data)
    return response.data
  }

  /// Get all recordings.
  public func recordings() async throws -> PagableResponse<[Recording]> {
    let url = baseURL.appendingPathComponent("recordings")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(PagableResponse<[Recording]>.self, from: data)
    return response
  }

  /// Get the active recording for a meeting.
  public func activeRecording(for meetingId: Meeting.ID) async throws -> Recording {
    let url = baseURL.appendingPathComponent("recordings")
      .appending(
        queryItems: [
          URLQueryItem(name: "meeting_id", value: meetingId.uuidString),
          URLQueryItem(name: "status", value: "RECORDING"),
        ])
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Recording>.self, from: data)
    return response.data
  }

  /// Pause, resume, or stop a recording.
  @discardableResult
  public func updateRecording(
    for recordingId: Recording.ID,
    action: RecordingAction
  ) async throws -> Recording {
    let url = baseURL.appendingPathComponent("recordings/\(recordingId)")
    let request = HTTPRequest(
      method: .put,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(action)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Recording>.self, from: data)
    return response.data
  }
}

public struct RecordingAction: Encodable, Sendable {
  public var action: Action

  public enum Action: String, Encodable, Sendable {
    case pause
    case resume
    case stop
  }

  public static let pause = RecordingAction(action: .pause)
  public static let resume = RecordingAction(action: .resume)
  public static let stop = RecordingAction(action: .stop)
}

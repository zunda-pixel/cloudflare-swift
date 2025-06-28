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
    let response = try JSONDecoder().decode(PagableResponse<SessionsResponse>.self, from: data)
    return response.data.sessions
  }
  
  public func session(for sessionId: Session.ID) async throws -> Session {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Session>.self, from: data)
    return response.data
  }
  
  public func sessionParticipants(for sessionId: Session.ID) async throws -> [Session.User] {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)/participants")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(PagableResponse<PaticipantsResponse>.self, from: data)
    return response.data.participants
  }
  
  public func sessionParticipant(for sessionId: Session.ID, participantId: Session.User.ID) async throws -> Session.User {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)/participants/\(participantId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<PaticipantResponse>.self, from: data)
    return response.data.participant
  }
  
  public func sessionChat(for sessionId: Session.ID) async throws -> ChatResponse {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)/chat")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<ChatResponse>.self, from: data)
    return response.data
  }

  public func sessionTranscript(for sessionId: Session.ID) async throws -> TranscriptResponse {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)/transcript")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<TranscriptResponse>.self, from: data)
    return response.data
  }
  
  public func sessionSummaryTranscript(for sessionId: Session.ID) async throws -> SummaryTranscriptResponse {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)/summary")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<SummaryTranscriptResponse>.self, from: data)
    return response.data
  }
  
  public func generateSessionSummaryTranscript(for sessionId: Session.ID) async throws -> GenerateSessionSummaryTranscriptResponse {
    let url = baseURL.appendingPathComponent("sessions/\(sessionId)/summary")
    let request = HTTPRequest(
      method: .post,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<GenerateSessionSummaryTranscriptResponse>.self, from: data)
    return response.data
  }

  public func peer(for peerId: Session.User.ID) async throws -> Session.User {
    let url = baseURL.appendingPathComponent("sessions/peer-report/\(peerId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<PaticipantResponse>.self, from: data)
    return response.data.participant
  }
}

private struct SessionsResponse: Decodable {
  var sessions: [Session]
}

private struct PaticipantsResponse: Decodable {
  var participants: [Session.User]
}

private struct PaticipantResponse: Decodable {
  var participant: Session.User
}

public struct GenerateSessionSummaryTranscriptResponse: Decodable {
  public var success: Bool
  public var message: String
}

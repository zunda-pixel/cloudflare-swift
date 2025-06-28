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

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import RealtimeKit
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct SessionAPITests {
  let client = Client(
    organizationId: ProcessInfo.processInfo.environment["REALTIMEKIT_ORGANIZATION_ID"]!,
    apiKey: ProcessInfo.processInfo.environment["REALTIMEKIT_API_KEY"]!,
    httpClient: .urlSession(.shared)
  )
  
  @Test
  func sessions() async throws {
    let sessions = try await client.sessions()
    print(sessions)
  }
  
  @Test(arguments: [UUID(uuidString: "8c377089-cede-4335-8489-89ab39a9cc88")!])
  func sessions(sessionId: Session.ID) async throws {
    let sessions = try await client.session(for: sessionId)
    print(sessions)
  }
  
  @Test(arguments: [
    UUID(uuidString: "8c377089-cede-4335-8489-89ab39a9cc88")!
  ])
  func sessionParticipants(sessionId: Session.ID) async throws {
    let sessions = try await client.sessionParticipants(for: sessionId)
    print(sessions)
  }
  
  @Test(arguments: [
    (UUID(uuidString: "8c377089-cede-4335-8489-89ab39a9cc88")!, UUID(uuidString: "7b417b23-5cd0-461b-8a71-82d9532e2e78")!)
  ])
  func sessionParticipant(sessionId: Session.ID, participantId: Session.User.ID) async throws {
    let participant = try await client.sessionParticipant(for: sessionId, participantId: participantId)
    print(participant)
  }
  
  @Test(arguments: [
    UUID(uuidString: "8c377089-cede-4335-8489-89ab39a9cc88")!
  ])
  func sessionChat(sessionId: Session.ID) async throws {
    let chat = try await client.sessionChat(for: sessionId)
    print(chat)
  }
}

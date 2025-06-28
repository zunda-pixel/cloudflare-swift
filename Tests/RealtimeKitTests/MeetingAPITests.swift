import Foundation
import HTTPTypes
import HTTPTypesFoundation
import RealtimeKit
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct MeetingAPITests {
  let client = Client(
    organizationId: ProcessInfo.processInfo.environment["REALTIMEKIT_ORGANIZATION_ID"]!,
    apiKey: ProcessInfo.processInfo.environment["REALTIMEKIT_API_KEY"]!,
    httpClient: .urlSession(.shared)
  )

  @Test
  func meetings() async throws {
    let meetings = try await client.meetings()
    print(meetings)
  }

  @Test(
    arguments: [
      UUID(uuidString: "bbbb1a07-43f7-4d91-956c-8fca958ca6e7")!
    ]
  )
  func meeting(meetingId: Meeting.ID) async throws {
    let meeting = try await client.meeting(for: meetingId)
    print(meeting)
  }

  @Test
  func createMeeting() async throws {
    let meeting = NewMeeting(
      title: "Title1",
      preferredRegion: .apSoutheast1,
      recordingConfig: .init(
        maxSeconds: 60,
        fileNamePrefix: "string",
        realtimeKitBucketConfig: .init(enabled: true)
      ),
      aiConfig: .init(
        transcription: .init(
          keywords: ["string"]
        )
      )
    )
    let meetings = try await client.createMeeting(meeting)
    print(meetings)
  }

  @Test
  func replaceMeeting() async throws {
    let newMeting = NewMeeting(
      title: "Title1",
      preferredRegion: .apSoutheast1,
      recordingConfig: .init(
        maxSeconds: 60,
        fileNamePrefix: "string",
        realtimeKitBucketConfig: .init(enabled: true)
      ),
      aiConfig: .init(
        transcription: .init(
          keywords: ["string"]
        )
      )
    )
    let meeting1 = try await client.createMeeting(newMeting)
    let meeting2 = try await client.replaceMeeting(for: meeting1.id, meeting: newMeting)
  }

  @Test(
    arguments: [
      UUID(uuidString: "bbb3043e-557a-41b6-93c7-33273ed8e739")!
    ]
  )
  func meetingParticipants(meetingId: Meeting.ID) async throws {
    let participants = try await client.participants(for: meetingId)
    print(participants)
  }

  @Test(
    arguments: [
      UUID(uuidString: "bbb3043e-557a-41b6-93c7-33273ed8e739")!
    ]
  )
  func addParticipant(meetingId: Meeting.ID) async throws {
    let newUser = Meeting.NewUser(
      name: "NewUser",
      customParticipantId: "CustomParticipantId",
      preset: .livestreamHost,
      picture: URL(string: "https://i.imgur.com/test.jpg")!
    )
    let participants = try await client.addParticipant(for: meetingId, participant: newUser)
    print(participants)
  }

  @Test(
    arguments: [
      (
        UUID(uuidString: "bbb3043e-557a-41b6-93c7-33273ed8e739")!,
        UUID(uuidString: "AAA22103-8303-424F-9073-906E4E59B392")!
      )
    ]
  )
  func participant(meetingId: Meeting.ID, participantId: Meeting.User.ID) async throws {
    let participant = try await client.participant(for: meetingId, participantId: participantId)
    print(participant)
  }

  @Test(
    arguments: [
      (
        UUID(uuidString: "bbb3043e-557a-41b6-93c7-33273ed8e739")!,
        UUID(uuidString: "AAA22103-8303-424F-9073-906E4E59B392")!
      )
    ]
  )
  func updateParticipant(meetingId: Meeting.ID, participantId: Meeting.User.ID) async throws {
    let updateUser = UpdateUser(
      name: "NewName",
      picture: URL(string: "https://i.imgur.com/new.jpg")!,
      preset: .groupCallHost
    )
    let participant = try await client.updateParticipant(
      for: meetingId,
      participantId: participantId,
      user: updateUser
    )

    #expect(updateUser.name == participant.name)
    #expect(updateUser.picture == participant.picture)
    // paticipant has no preset(_name)
    // #expect(updateUser.preset == participant.preset)
  }

  @Test(
    arguments: [
      (
        UUID(uuidString: "bbb3043e-557a-41b6-93c7-33273ed8e739")!,
        UUID(uuidString: "AAADE067-28E7-47A4-A6DA-381922D217B7")!
      )
    ]
  )
  func deleteParticipant(meetingId: Meeting.ID, participantId: Meeting.User.ID) async throws {
    let deletedParticipant = try await client.deleteParticipant(
      for: meetingId,
      participantId: participantId
    )
    print(deletedParticipant)
  }

  @Test(
    arguments: [
      (
        UUID(uuidString: "bbb3043e-557a-41b6-93c7-33273ed8e739")!,
        UUID(uuidString: "AAA35254-6C6F-4853-AC2A-82BEE7F8F365")!
      )
    ]
  )
  func refreshParticipantToekn(meetingId: Meeting.ID, participantId: Meeting.User.ID) async throws {
    let newToken = try await client.refreshParticipantToken(
      for: meetingId,
      participantId: participantId
    )
    print(newToken)
  }
}

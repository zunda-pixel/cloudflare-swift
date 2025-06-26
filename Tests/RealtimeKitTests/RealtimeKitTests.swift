import Foundation
import HTTPTypes
import HTTPTypesFoundation
import RealtimeKit
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct RealtimeKitTests {
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
    UUID(uuidString: "bbbb1a07-43f7-4d91-956c-8fca958ca6e7")!]
  )
  func meeting(meetingId: Meeting.ID) async throws {
    let meeting = try await client.meeting(for: meetingId)
    print(meeting)
  }

  @Test
  func createMeeting() async throws {
    let meeting = CreateMeeting(
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
}

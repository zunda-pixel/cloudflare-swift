import Foundation
import HTTPTypes
import HTTPTypesFoundation
import RealtimeKit
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct RecordingAPITests {
  let client = Client(
    organizationId: ProcessInfo.processInfo.environment["REALTIMEKIT_ORGANIZATION_ID"]!,
    apiKey: ProcessInfo.processInfo.environment["REALTIMEKIT_API_KEY"]!,
    httpClient: .urlSession(.shared)
  )

  @Test
  func recordings() async throws {
    let recordings = try await client.recordings()
    print(recordings)
  }

  @Test(
    arguments: [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ]
  )
  func recording(recordingId: Recording.ID) async throws {
    let recording = try await client.recording(for: recordingId)
    print(recording)
  }

  @Test(
    arguments: [
      UUID(uuidString: "bbbb1a07-43f7-4d91-956c-8fca958ca6e7")!
    ]
  )
  func startRecording(meetingId: Meeting.ID) async throws {
    let startRecording = StartRecording(meetingId: meetingId)
    let recording = try await client.startRecording(startRecording)
    print(recording)
  }

  @Test(
    arguments: [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ]
  )
  func stopRecording(recordingId: Recording.ID) async throws {
    let recording = try await client.updateRecording(for: recordingId, action: .stop)
    print(recording)
  }
}

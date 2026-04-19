import Foundation
import HTTPTypes
import HTTPTypesFoundation
import RealtimeKit
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct LivestreamAPITests {
  let client = Client(
    organizationId: ProcessInfo.processInfo.environment["REALTIMEKIT_ORGANIZATION_ID"]!,
    apiKey: ProcessInfo.processInfo.environment["REALTIMEKIT_API_KEY"]!,
    httpClient: .urlSession(.shared)
  )

  @Test
  func livestreams() async throws {
    let livestreams = try await client.livestreams()
    print(livestreams)
  }

  @Test(
    arguments: [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ]
  )
  func livestream(livestreamId: Livestream.ID) async throws {
    let livestream = try await client.livestream(for: livestreamId)
    print(livestream)
  }

  @Test
  func createLivestream() async throws {
    let newLivestream = NewLivestream(name: "TestLivestream")
    let livestream = try await client.createLivestream(newLivestream)
    print(livestream)
  }
}

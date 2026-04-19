import Foundation
import HTTPTypes
import HTTPTypesFoundation
import RealtimeKit
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct WebhookAPITests {
  let client = Client(
    organizationId: ProcessInfo.processInfo.environment["REALTIMEKIT_ORGANIZATION_ID"]!,
    apiKey: ProcessInfo.processInfo.environment["REALTIMEKIT_API_KEY"]!,
    httpClient: .urlSession(.shared)
  )

  @Test
  func webhooks() async throws {
    let webhooks = try await client.webhooks()
    print(webhooks)
  }

  @Test(
    arguments: [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ]
  )
  func webhook(webhookId: Webhook.ID) async throws {
    let webhook = try await client.webhook(for: webhookId)
    print(webhook)
  }

  @Test
  func createWebhook() async throws {
    let newWebhook = NewWebhook(
      name: "TestWebhook",
      url: URL(string: "https://example.com/webhook")!,
      events: [.meetingStarted, .meetingEnded]
    )
    let webhook = try await client.createWebhook(newWebhook)
    print(webhook)
  }

  @Test(
    arguments: [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ]
  )
  func updateWebhook(webhookId: Webhook.ID) async throws {
    let update = UpdateWebhook(
      name: "UpdatedWebhook"
    )
    let webhook = try await client.updateWebhook(for: webhookId, webhook: update)
    print(webhook)
  }

  @Test(
    arguments: [
      UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    ]
  )
  func deleteWebhook(webhookId: Webhook.ID) async throws {
    let webhook = try await client.deleteWebhook(for: webhookId)
    print(webhook)
  }
}

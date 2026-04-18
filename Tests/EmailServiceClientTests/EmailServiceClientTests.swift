import EmailServiceClient
import Foundation
import HTTPTypesFoundation
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@Suite
struct EmailServiceClientTests {
  let client = EmailServiceClient(
    apiToken: ProcessInfo.processInfo.environment["EMAIL_SERVICE_API_TOKEN"]!,
    accountId: ProcessInfo.processInfo.environment["ACCOUNT_ID"]!,
    httpClient: .urlSession(.shared)
  )

  @Test
  func sendEmail() async throws {
    let result = try await client.send(
      EmailMessage(
        to: "zunda.dev@gmail.com",
        from: "zunda.dev@blindlog.me",
        subject: "Cloudflare Swift EmailServiceClient Test",
        text: "This is a test email from EmailServiceClient."
      )
    )

    #expect(result.delivered.isEmpty)
    #expect(result.queued.isEmpty)
  }

  @Test
  func decodeSendEmailResult() throws {
    let payload = """
      {
        "result": {
          "delivered": ["delivered@example.com"],
          "permanent_bounces": ["bounced@example.com"],
          "queued": ["queued@example.com"]
        },
        "success": true,
        "errors": [],
        "messages": []
      }
      """.data(using: .utf8)!

    let response = try JSONDecoder().decode(EmailResponse.self, from: payload)

    #expect(response.success == true)
    #expect(response.result?.delivered == ["delivered@example.com"])
    #expect(response.result?.permanentBounces == ["bounced@example.com"])
    #expect(response.result?.queued == ["queued@example.com"])
  }
}

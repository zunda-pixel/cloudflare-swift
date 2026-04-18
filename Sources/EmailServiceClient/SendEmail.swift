import Foundation
import HTTPTypes

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension EmailServiceClient {
  /// Send email via Cloudflare Email Service REST API.
  /// https://developers.cloudflare.com/email-service/api/send-emails/rest-api/
  /// - Parameter email: Email payload.
  /// - Returns: Delivery status for recipients.
  public func send(_ email: EmailMessage) async throws -> EmailResponse.Result {
    let url = baseURL.appendingPathComponent("accounts/\(accountId)/email/sending/send")

    let request = HTTPRequest(
      method: .post,
      url: url
    )

    let body = try JSONEncoder().encode(email)
    let (data, _) = try await execute(request, body: body)
    let response = try JSONDecoder().decode(EmailResponse.self, from: data)

    if let result = response.result, response.success {
      return result
    } else {
      throw Self.handleError(errors: response.errors)
    }
  }
}

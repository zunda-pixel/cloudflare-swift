import Foundation
import HTTPTypes

extension Client {
  /// Get all webhooks.
  public func webhooks() async throws -> PagableResponse<[Webhook]> {
    let url = baseURL.appendingPathComponent("webhooks")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(PagableResponse<[Webhook]>.self, from: data)
    return response
  }

  /// Get details of a specific webhook.
  public func webhook(for webhookId: Webhook.ID) async throws -> Webhook {
    let url = baseURL.appendingPathComponent("webhooks/\(webhookId)")
    let request = HTTPRequest(
      method: .get,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Webhook>.self, from: data)
    return response.data
  }

  /// Create a new webhook.
  @discardableResult
  public func createWebhook(_ webhook: NewWebhook) async throws -> Webhook {
    let url = baseURL.appendingPathComponent("webhooks")
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(webhook)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Webhook>.self, from: data)
    return response.data
  }

  /// Update a webhook.
  @discardableResult
  public func updateWebhook(
    for webhookId: Webhook.ID,
    webhook: UpdateWebhook
  ) async throws -> Webhook {
    let url = baseURL.appendingPathComponent("webhooks/\(webhookId)")
    let request = HTTPRequest(
      method: .patch,
      url: url,
      headerFields: [
        .contentType: "application/json"
      ]
    )
    let bodyData = try JSONEncoder().encode(webhook)
    let (data, _) = try await execute(request, body: bodyData)
    let response = try JSONDecoder().decode(SingleResponse<Webhook>.self, from: data)
    return response.data
  }

  /// Delete a webhook.
  @discardableResult
  public func deleteWebhook(for webhookId: Webhook.ID) async throws -> Webhook {
    let url = baseURL.appendingPathComponent("webhooks/\(webhookId)")
    let request = HTTPRequest(
      method: .delete,
      url: url
    )
    let (data, _) = try await execute(request)
    let response = try JSONDecoder().decode(SingleResponse<Webhook>.self, from: data)
    return response.data
  }
}

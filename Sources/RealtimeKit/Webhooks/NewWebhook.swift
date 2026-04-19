import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct NewWebhook: Encodable, Sendable {
  public var name: String
  public var url: URL
  public var events: [Webhook.Event]
}

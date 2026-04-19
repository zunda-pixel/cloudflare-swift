import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct UpdateWebhook: Encodable, Sendable {
  public var name: String? = nil
  public var url: URL? = nil
  public var events: [Webhook.Event]? = nil
}

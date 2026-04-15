import Foundation

/// DNS API message content for errors and informational messages
public struct DNSMessageContent: Error, Sendable, Codable, Hashable {
  /// Error or message code from the API
  public var code: Int

  /// Human-readable error or message text
  public var message: String

  /// Initialize a new DNS message content
  /// - Parameters:
  ///   - code: Error or message code
  ///   - message: Human-readable message text
  public init(code: Int, message: String) {
    self.code = code
    self.message = message
  }
}

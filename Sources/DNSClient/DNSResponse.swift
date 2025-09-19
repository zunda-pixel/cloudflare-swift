import Foundation

/// DNS API response wrapper following Cloudflare API response format
public struct DNSResponse<Result: Sendable & Codable & Hashable>: Sendable, Codable, Hashable {
  /// The result data from the API call
  public var result: Result?

  /// Whether the API call was successful
  public var success: Bool

  /// Array of error messages if the call failed
  public var errors: [DNSMessageContent]

  /// Array of informational messages from the API
  public var messages: [DNSMessageContent]
}

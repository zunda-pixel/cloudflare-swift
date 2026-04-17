import Foundation

public struct EmailResponse: Sendable, Codable, Hashable {
  public var result: Result?
  public var success: Bool
  public var errors: [MessageContent]
  public var messages: [MessageContent]

  public struct Result: Sendable, Codable, Hashable {
    public var delivered: [String]
    public var permanentBounces: [String]
    public var queued: [String]

    private enum CodingKeys: String, CodingKey {
      case delivered
      case permanentBounces = "permanent_bounces"
      case queued
    }
  }
}

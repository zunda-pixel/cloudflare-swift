import Foundation

public struct ImagesResponse<Result: Sendable & Codable & Hashable>: Sendable, Codable, Hashable {
  public var result: Result?
  public var success: Bool
  public var errors: [MessageContent]
  public var messages: [MessageContent]
}

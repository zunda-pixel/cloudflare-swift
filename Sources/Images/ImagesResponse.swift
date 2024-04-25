import Foundation

public struct ImagesResponse<Result>: Sendable, Codable, Hashable where Result: Sendable, Result: Codable, Result: Hashable {
  public var result: Result?
  public var success: Bool
  public var errors: [MessageContent]
  public var messages: [MessageContent]
}

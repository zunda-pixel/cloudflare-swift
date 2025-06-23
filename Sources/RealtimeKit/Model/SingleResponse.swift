import Foundation

public struct SingleResponse<Content: Codable>: Codable {
  public var success: Bool
  public var data: Content
}

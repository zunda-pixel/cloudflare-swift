import Foundation

public struct SingleResponse<Content: Decodable>: Decodable {
  public var success: Bool
  public var data: Content
}

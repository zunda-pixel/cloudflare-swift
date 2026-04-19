public struct MessageContent: Error, Sendable, Codable, Hashable {
  public var code: Int
  public var message: String
}

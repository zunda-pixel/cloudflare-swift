public struct ErrorContent: Error, Sendable, Codable, Hashable {
  public var code: Int
  public var message: String
}

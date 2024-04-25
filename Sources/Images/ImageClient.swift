public struct ImageClient {
  public let token: String
  public let accountId: String
  
  public init(
    token: String,
    accountId: String
  ) {
    self.token = token
    self.accountId = accountId
  }
}

public struct ImagesClient {
  public let apiToken: String
  public let accountId: String

  public init(
    apiToken: String,
    accountId: String
  ) {
    self.apiToken = apiToken
    self.accountId = accountId
  }
}

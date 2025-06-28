import Foundation

public struct ChatResponse: Decodable {
  public var chatDownloadURL: URL
  public var chatDownloadExpiry: Date
  
  enum CodingKeys: String, CodingKey {
    case chatDownloadURL = "chat_download_url"
    case chatDownloadExpiry = "chat_download_url_expiry"
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.chatDownloadURL = try container.decode(URL.self, forKey: .chatDownloadURL)
    self.chatDownloadExpiry = try Date(container.decode(String.self, forKey: .chatDownloadExpiry), strategy: .iso8601WithFractionalSeconds)
  }
}

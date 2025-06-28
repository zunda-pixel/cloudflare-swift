import Foundation

public struct TranscriptResponse: Decodable {
  public var downloadURL: URL
  public var downloadExpiry: Date
  
  enum CodingKeys: String, CodingKey {
    case downloadURL = "transcript_download_url"
    case downloadExpiry = "transcript_download_url_expiry"
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.downloadURL = try container.decode(URL.self, forKey: .downloadURL)
    self.downloadExpiry = try Date(container.decode(String.self, forKey: .downloadExpiry), strategy: .iso8601WithFractionalSeconds)
  }
}

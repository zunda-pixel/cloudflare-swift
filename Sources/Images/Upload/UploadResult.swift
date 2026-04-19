import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct Image: Sendable, Codable, Hashable {
  public var id: String
  public var fileName: String?
  public var metadatas: [String: String]?
  public var uploadedDate: Date
  public var requireSignedURLs: Bool
  public var variants: [URL]

  private enum CodingKeys: String, CodingKey {
    case id
    case fileName = "filename"
    case metadatas = "meta"
    case uploadedDate = "uploaded"
    case requireSignedURLs
    case variants
  }
}

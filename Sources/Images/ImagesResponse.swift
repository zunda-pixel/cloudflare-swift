import Foundation

public struct ImagesResponse: Sendable, Codable, Hashable {
  public var result: Result?
  public var success: Bool
  public var errors: [MessageContent]
  public var messages: [MessageContent]
  
  public struct Result: Sendable, Codable, Hashable {
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
}

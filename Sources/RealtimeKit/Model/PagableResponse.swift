import Foundation

public struct PagableResponse<Content: Decodable>: Decodable {
  public var success: Bool
  public var data: Content
  public var paging: Paging
}

extension PagableResponse {
  public struct Paging: Codable {
    public var totalCount: Int
    public var startOffset: Int
    public var endOffset: Int
    
    private enum CodingKeys: String, CodingKey {
      case totalCount = "total_count"
      case startOffset = "start_offset"
      case endOffset = "end_offset"
    }
  }
}

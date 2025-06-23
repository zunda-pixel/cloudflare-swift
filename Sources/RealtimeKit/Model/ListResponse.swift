import Foundation

public struct ListResponse<Element: Codable>: Codable {
  public var success: Bool
  public var data: [Element]
  public var paging: Paging
}

extension ListResponse {
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

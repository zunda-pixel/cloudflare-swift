import Foundation

extension CGSize: Codable {
  private enum CodingKeys: String, CodingKey {
    case width
    case height
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let width = try container.decode(CGFloat.self, forKey: .width)
    let height = try container.decode(CGFloat.self, forKey: .height)
    self.init(width: width, height: height)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.width, forKey: .width)
    try container.encode(self.height, forKey: .height)
  }
}

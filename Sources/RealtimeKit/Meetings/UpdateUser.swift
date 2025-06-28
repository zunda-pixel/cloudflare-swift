import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct UpdateUser: Codable, Sendable, Hashable {
  public var name: String?
  public var picture: URL?
  public var preset: Preset?
  
  private enum CodingKeys: String, CodingKey {
    case name
    case picture
    case preset = "preset_name"
  }
}

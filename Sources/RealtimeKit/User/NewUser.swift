import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct NewUser: Codable, Sendable, Hashable {
  public var name: String
  public var customParticipantId: String
  public var preset: User.Preset
  public var picture: URL?
  
  private enum CodingKeys: String, CodingKey {
    case name
    case customParticipantId = "custom_participant_id"
    case preset = "preset_name"
    case picture
  }
}

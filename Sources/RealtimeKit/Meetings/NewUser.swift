import Foundation
import MemberwiseInit

extension Meeting {
  @MemberwiseInit(.public)
  public struct NewUser: Codable, Sendable, Hashable {
    public var name: String
    public var customParticipantId: String
    public var preset: Preset
    public var picture: URL?
    
    private enum CodingKeys: String, CodingKey {
      case name
      case customParticipantId = "custom_participant_id"
      case preset = "preset_name"
      case picture
    }
  }
}

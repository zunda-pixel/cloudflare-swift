import Foundation
import MemberwiseInit

@MemberwiseInit()
public struct User: Codable, Sendable, Hashable, Identifiable {
  public var id: UUID
  public var name: String
  public var customParticipantId: String
  public var preset: Preset?
  public var presetId: UUID?
  public var picture: URL?
  public var token: String?
  public var sipEnabled: Bool?
  public var createdAt: Date
  public var updatedAt: Date
  
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case customParticipantId = "custom_participant_id"
    case preset = "preset_name"
    case presetId = "preset_id"
    case picture
    case token
    case sipEnabled = "sip_enabled"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.customParticipantId = try container.decode(String.self, forKey: .customParticipantId)
    self.preset = try container.decodeIfPresent(Preset.self, forKey: .preset)
    self.presetId = try container.decodeIfPresent(UUID.self, forKey: .presetId)
    self.picture = try container.decodeIfPresent(URL.self, forKey: .picture)
    self.token = try container.decodeIfPresent(String.self, forKey: .token)
    self.sipEnabled = try container.decodeIfPresent(Bool.self, forKey: .sipEnabled)
    self.createdAt = try Date(container.decode(String.self, forKey: .createdAt), strategy: .iso8601WithFractionalSeconds)
    self.updatedAt = try Date(container.decode(String.self, forKey: .updatedAt), strategy: .iso8601WithFractionalSeconds)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.customParticipantId, forKey: .customParticipantId)
    try container.encodeIfPresent(self.preset, forKey: .preset)
    try container.encodeIfPresent(self.presetId, forKey: .presetId)
    try container.encodeIfPresent(self.picture, forKey: .picture)
    try container.encodeIfPresent(self.token, forKey: .token)
    try container.encodeIfPresent(self.sipEnabled, forKey: .sipEnabled)
    try container.encode(self.createdAt.formatted(.iso8601WithFractionalSeconds), forKey: .createdAt)
    try container.encode(self.updatedAt.formatted(.iso8601WithFractionalSeconds), forKey: .updatedAt)
  }
  
  @MemberwiseInit(.public)
  public struct Preset: Sendable, Codable, Hashable, RawRepresentable {
    public var rawValue: String
    
    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.rawValue = try container.decode(String.self)
    }
    
    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }
    
    public static let groupCallHost = Self(rawValue: "group_call_host")
    public static let groupCallParticipant = Self(rawValue: "group_call_participant")
    public static let livestreamHost = Self(rawValue: "livestream_host")
    public static let livestreamViewer = Self(rawValue: "livestream_viewer")
    public static let webinarHost = Self(rawValue: "webinar_host")
    public static let webinarViewer = Self(rawValue: "webinar_viewer")
  }
}

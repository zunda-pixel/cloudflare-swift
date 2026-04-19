import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Webhook: Codable, Sendable, Identifiable {
  public var id: UUID
  public var name: String
  public var url: URL
  public var events: [Event]
  public var status: Status?
  public var createdAt: Date
  public var updatedAt: Date

  public enum Status: String, Codable, Sendable, Hashable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
  }

  public enum Event: String, Codable, Sendable, Hashable {
    case meetingStarted = "meeting.started"
    case meetingEnded = "meeting.ended"
    case meetingParticipantJoined = "meeting.participantJoined"
    case meetingParticipantLeft = "meeting.participantLeft"
    case meetingChatSynced = "meeting.chatSynced"
    case meetingTranscript = "meeting.transcript"
    case meetingSummary = "meeting.summary"
    case recordingStatusUpdate = "recording.statusUpdate"
    case livestreamingStatusUpdate = "livestreaming.statusUpdate"
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case url
    case events
    case status
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.url = try container.decode(URL.self, forKey: .url)
    self.events = try container.decode([Event].self, forKey: .events)
    self.status = try container.decodeIfPresent(Status.self, forKey: .status)
    self.createdAt = try Date(
      container.decode(String.self, forKey: .createdAt),
      strategy: .iso8601WithFractionalSeconds
    )
    self.updatedAt = try Date(
      container.decode(String.self, forKey: .updatedAt),
      strategy: .iso8601WithFractionalSeconds
    )
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.url, forKey: .url)
    try container.encode(self.events, forKey: .events)
    try container.encodeIfPresent(self.status, forKey: .status)
    try container.encode(
      self.createdAt.formatted(.iso8601WithFractionalSeconds),
      forKey: .createdAt
    )
    try container.encode(
      self.updatedAt.formatted(.iso8601WithFractionalSeconds),
      forKey: .updatedAt
    )
  }
}

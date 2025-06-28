import Foundation
import MemberwiseInit


@MemberwiseInit(.public)
public struct Session: Codable, Hashable, Sendable, Identifiable {
  public var id: UUID
  public var associatedId: String
  public var meetingDisplayName: String
  public var type: SessionType
  public var status: Status
  public var liveParticipants: Int
  public var maxConcurrentParticipants: Int
  public var recoringStatus: RecodingStatus
  public var liveStreamStatus: LiveStreamStatus
  public var totalParticipants: Int
  public var minutesConsumed: Double
  public var groupCallMinutesConsumed: Double
  public var webinarMinutesConsumed: Double
  public var audioRoomMinutesConsumed: Double
  public var liveStreamMinutesConsumed: Double
  public var chatMinutesConsumed: Double
  public var recordingMinutesConsumed: Double
  public var transcriptionMinutesConsumed: Double
  public var organizationId: UUID
  public var parentSessionId: UUID?
  public var settings: Settings
  public var startedAt: Date
  public var createdAt: Date
  public var updatedAt: Date
  public var endedAt: Date?
  public var meta: Meta
  public var breakoutRooms: [Session]?
  
  private enum CodingKeys: String, CodingKey {
    case id
    case associatedId = "associated_id"
    case meetingDisplayName = "meeting_display_name"
    case type
    case status
    case liveParticipants = "live_participants"
    case maxConcurrentParticipants = "max_concurrent_participants"
    case recordingStatus = "recording_status"
    case liveStreamStatus = "livestream_status"
    case totalParticipants = "total_participants"
    case minutesConsumed = "minutes_consumed"
    case groupCallMinutesConsumed = "group_call_minutes_consumed"
    case webinarMinutesConsumed = "webinar_minutes_consumed"
    case audioRoomMinutesConsumed = "audio_room_minutes_consumed"
    case liveStreamMinutesConsumed = "livestream_minutes_consumed"
    case chatMinutesConsumed = "chat_minutes_consumed"
    case recordingMinutesConsumed = "recording_minutes_consumed"
    case transcriptionMinutesConsumed = "transcription_minutes_consumed"
    case organizationId = "organization_id"
    case parentSessionId = "parent_session_id"
    case settings
    case startedAt = "started_at"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case endedAt = "ended_at"
    case meta
    case breakoutRooms = "breakout_rooms"
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.associatedId = try container.decode(String.self, forKey: .associatedId)
    self.meetingDisplayName = try container.decode(String.self, forKey: .meetingDisplayName)
    self.type = try container.decode(SessionType.self, forKey: .type)
    self.status = try container.decode(Status.self, forKey: .status)
    self.liveParticipants = try container.decode(Int.self, forKey: .liveParticipants)
    self.maxConcurrentParticipants = try container.decode(Int.self, forKey: .maxConcurrentParticipants)
    self.recoringStatus = try container.decode(RecodingStatus.self, forKey: .recordingStatus)
    self.liveStreamStatus = try container.decode(LiveStreamStatus.self, forKey: .liveStreamStatus)
    self.totalParticipants = try container.decode(Int.self, forKey: .totalParticipants)
    self.minutesConsumed = try container.decode(Double.self, forKey: .minutesConsumed)
    self.groupCallMinutesConsumed = try container.decode(Double.self, forKey: .groupCallMinutesConsumed)
    self.webinarMinutesConsumed = try container.decode(Double.self, forKey: .webinarMinutesConsumed)
    self.audioRoomMinutesConsumed = try container.decode(Double.self, forKey: .audioRoomMinutesConsumed)
    self.liveStreamMinutesConsumed = try container.decode(Double.self, forKey: .liveStreamMinutesConsumed)
    self.chatMinutesConsumed = try container.decode(Double.self, forKey: .chatMinutesConsumed)
    self.recordingMinutesConsumed = try container.decode(Double.self, forKey: .recordingMinutesConsumed)
    self.transcriptionMinutesConsumed = try container.decode(Double.self, forKey: .transcriptionMinutesConsumed)
    self.organizationId = try container.decode(UUID.self, forKey: .organizationId)
    self.parentSessionId = try container.decodeIfPresent(UUID.self, forKey: .parentSessionId)
    self.settings = try container.decode(Settings.self, forKey: .settings)
    self.startedAt = try Date(container.decode(String.self, forKey: .startedAt), strategy: .iso8601WithFractionalSeconds)
    self.createdAt = try Date(container.decode(String.self, forKey: .createdAt), strategy: .iso8601WithFractionalSeconds)
    self.updatedAt = try Date(container.decode(String.self, forKey: .updatedAt), strategy: .iso8601WithFractionalSeconds)
    self.endedAt = try container.decodeIfPresent(String.self, forKey: .endedAt).map { try Date($0, strategy: .iso8601WithFractionalSeconds) }
    self.meta = try container.decode(Meta.self, forKey: .meta)
    self.breakoutRooms = try container.decodeIfPresent([Session].self, forKey: .breakoutRooms)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.associatedId, forKey: .associatedId)
    try container.encode(self.meetingDisplayName, forKey: .meetingDisplayName)
    try container.encode(self.type, forKey: .type)
    try container.encode(self.status, forKey: .status)
    try container.encode(self.liveParticipants, forKey: .liveParticipants)
    try container.encode(self.maxConcurrentParticipants, forKey: .maxConcurrentParticipants)
    try container.encode(self.recoringStatus, forKey: .recordingStatus)
    try container.encode(self.liveStreamStatus, forKey: .liveStreamStatus)
    try container.encode(self.totalParticipants, forKey: .totalParticipants)
    try container.encode(self.minutesConsumed, forKey: .minutesConsumed)
    try container.encode(self.groupCallMinutesConsumed, forKey: .groupCallMinutesConsumed)
    try container.encode(self.webinarMinutesConsumed, forKey: .webinarMinutesConsumed)
    try container.encode(self.audioRoomMinutesConsumed, forKey: .audioRoomMinutesConsumed)
    try container.encode(self.liveStreamMinutesConsumed, forKey: .liveStreamMinutesConsumed)
    try container.encode(self.chatMinutesConsumed, forKey: .chatMinutesConsumed)
    try container.encode(self.recordingMinutesConsumed, forKey: .recordingMinutesConsumed)
    try container.encode(self.transcriptionMinutesConsumed, forKey: .transcriptionMinutesConsumed)
    try container.encode(self.organizationId, forKey: .organizationId)
    try container.encodeIfPresent(self.parentSessionId, forKey: .parentSessionId)
    try container.encode(self.settings, forKey: .settings)
    try container.encode(self.startedAt.formatted(.iso8601WithFractionalSeconds), forKey: .startedAt)
    try container.encode(self.createdAt.formatted(.iso8601WithFractionalSeconds), forKey: .createdAt)
    try container.encode(self.updatedAt.formatted(.iso8601WithFractionalSeconds), forKey: .updatedAt)
    try container.encodeIfPresent(self.endedAt.map { $0.formatted(.iso8601WithFractionalSeconds) }, forKey: .endedAt)
    try container.encode(self.meta, forKey: .meta)
    try container.encodeIfPresent(self.breakoutRooms, forKey: .breakoutRooms)
  }
  
  public enum RecodingStatus: String, Codable, Hashable, Sendable {
    case notRecoded = "NOT_RECORDED"
    case uploaded = "UPLOADED"
  }
  
  public enum LiveStreamStatus: String, Codable, Hashable, Sendable {
    case notLiveStreamed = "NOT_LIVESTREAMED"
  }
  
  @MemberwiseInit(.public)
  public struct Settings: Codable, Hashable, Sendable {
    
  }
  
  public enum Status: String, Codable, Hashable, Sendable {
    case live = "LIVE"
    case ended = "ENDED"
  }
  
  public enum SessionType: String, Codable, Hashable, Sendable {
    case meeting
    case livestream
    case participant
  }
  
  @MemberwiseInit(.public)
  public struct Meta: Codable, Sendable, Hashable {
    public var roomName: UUID
    
    private enum CodingKeys: String, CodingKey {
      case roomName = "room_name"
    }
  }
}

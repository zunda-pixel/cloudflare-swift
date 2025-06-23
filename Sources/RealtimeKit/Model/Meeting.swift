import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Meeting: Codable, Sendable {
  public var id: UUID
  public var title: String
  public var status: Status
  public var preferredRegion: PreferredRegion?
  public var recordOnStart: Bool? = false
  public var liveStreamOnStart: Bool? = false
  public var persistChat: Bool? = false
  public var summarizeOnEnd: Bool? = false
  public var recordingConfig: RecordConfig?
  public var aiConfig: AIConfig?
  public var createdAt: Date
  public var updatedAt: Date
  
  public enum Status: String, Codable, Sendable, Hashable {
    case active = "ACTIVE"
  }
  
  public enum PreferredRegion: String, Codable, Sendable, Hashable {
    case apSouth1 = "ap-south-1"
    case apSoutheast1 = "ap-southeast-1"
    case usEast1 = "us-east-1"
    case enCentral1 = "eu-central-1"
  }
  
  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case status
    case preferredRegion = "preferred_region"
    case recordOnStart = "record_on_start"
    case liveStreamOnStart = "live_stream_on_start"
    case persistChat = "persist_chat"
    case summarizeOnEnd = "summarize_on_end"
    case recordingConfig = "recording_config"
    case aiConfig = "ai_config"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.status = try container.decode(Meeting.Status.self, forKey: .status)
    self.preferredRegion = try container.decodeIfPresent(PreferredRegion.self, forKey: .preferredRegion)
    self.recordOnStart = try container.decodeIfPresent(Bool.self, forKey: .recordOnStart)
    self.liveStreamOnStart = try container.decodeIfPresent(Bool.self, forKey: .liveStreamOnStart)
    self.persistChat = try container.decodeIfPresent(Bool.self, forKey: .persistChat)
    self.summarizeOnEnd = try container.decodeIfPresent(Bool.self, forKey: .summarizeOnEnd)
    self.recordingConfig = try container.decodeIfPresent(RecordConfig.self, forKey: .recordingConfig)
    self.aiConfig = try container.decodeIfPresent(AIConfig.self, forKey: .aiConfig)
    self.createdAt = try Date(container.decode(String.self, forKey: .createdAt), strategy: .iso8601WithFractionalSeconds)
    self.updatedAt = try Date(container.decode(String.self, forKey: .updatedAt), strategy: .iso8601WithFractionalSeconds)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.title, forKey: .title)
    try container.encode(self.status, forKey: .status)
    try container.encodeIfPresent(self.preferredRegion, forKey: .preferredRegion)
    try container.encodeIfPresent(self.recordOnStart, forKey: .recordOnStart)
    try container.encodeIfPresent(self.liveStreamOnStart, forKey: .liveStreamOnStart)
    try container.encodeIfPresent(self.persistChat, forKey: .persistChat)
    try container.encodeIfPresent(self.summarizeOnEnd, forKey: .summarizeOnEnd)
    try container.encode(self.recordingConfig, forKey: .recordingConfig)
    try container.encode(self.aiConfig, forKey: .aiConfig)
    try container.encode(self.createdAt.formatted(.iso8601WithFractionalSeconds), forKey: .createdAt)
    try container.encode(self.updatedAt.formatted(.iso8601WithFractionalSeconds), forKey: .updatedAt)
  }
}


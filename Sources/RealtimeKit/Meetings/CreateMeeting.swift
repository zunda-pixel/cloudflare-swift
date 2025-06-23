import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct CreateMeeting: Encodable, Sendable {
  public var title: String
  public var preferredRegion: Meeting.PreferredRegion
  public var recordOnStart: Bool = false
  public var liveStreamOnStart: Bool = false
  public var persistChat: Bool = false
  public var summarizeOnEnd: Bool = false
  public var recordingConfig: RecordConfig
  public var aiConfig: AIConfig = AIConfig()
  
  private enum CodingKeys: String, CodingKey {
    case title
    case preferredRegion = "preferred_region"
    case recordOnStart = "record_on_start"
    case liveStreamOnStart = "live_stream_on_start"
    case persistChat = "persist_chat"
    case summarizeOnEnd = "summarize_on_end"
    case recordingConfig = "recording_config"
    case aiConfig = "ai_config"
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.title, forKey: .title)
    try container.encode(self.preferredRegion, forKey: .preferredRegion)
    try container.encode(self.recordOnStart, forKey: .recordOnStart)
    try container.encode(self.liveStreamOnStart, forKey: .liveStreamOnStart)
    try container.encode(self.persistChat, forKey: .persistChat)
    try container.encode(self.summarizeOnEnd, forKey: .summarizeOnEnd)
    try container.encode(self.recordingConfig, forKey: .recordingConfig)
    try container.encode(self.aiConfig, forKey: .aiConfig)
  }
}


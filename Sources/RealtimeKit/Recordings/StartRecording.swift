import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct StartRecording: Encodable, Sendable {
  public var meetingId: UUID
  public var fileNamePrefix: String? = nil
  public var videoConfig: RecordConfig.VideoConfig? = nil
  public var audioConfig: RecordConfig.AudioConfig? = nil
  public var storageConfig: RecordConfig.StorageConfig? = nil
  public var realtimeKitBucketConfig: RecordConfig.RealtimeKitBucketConfig? = nil

  private enum CodingKeys: String, CodingKey {
    case meetingId = "meeting_id"
    case fileNamePrefix = "file_name_prefix"
    case videoConfig = "video_config"
    case audioConfig = "audio_config"
    case storageConfig = "storage_config"
    case realtimeKitBucketConfig = "realtimekit_bucket_config"
  }
}

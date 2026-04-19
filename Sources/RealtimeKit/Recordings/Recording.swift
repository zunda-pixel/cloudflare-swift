import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Recording: Codable, Sendable, Identifiable {
  public var id: UUID
  public var downloadURL: URL?
  public var downloadURLExpiry: Date?
  public var downloadAudioURL: URL?
  public var fileSize: Int?
  public var sessionId: UUID?
  public var outputFileName: String?
  public var status: Status
  public var invokedTime: Date?
  public var startedTime: Date?
  public var stoppedTime: Date?
  public var storageConfig: RecordConfig.StorageConfig?
  public var videoConfig: RecordConfig.VideoConfig?
  public var audioConfig: RecordConfig.AudioConfig?

  public enum Status: String, Codable, Sendable, Hashable {
    case invoked = "INVOKED"
    case recording = "RECORDING"
    case uploading = "UPLOADING"
    case uploaded = "UPLOADED"
    case errored = "ERRORED"
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case downloadURL = "download_url"
    case downloadURLExpiry = "download_url_expiry"
    case downloadAudioURL = "download_audio_url"
    case fileSize = "file_size"
    case sessionId = "session_id"
    case outputFileName = "output_file_name"
    case status
    case invokedTime = "invoked_time"
    case startedTime = "started_time"
    case stoppedTime = "stopped_time"
    case storageConfig = "storage_config"
    case videoConfig = "video_config"
    case audioConfig = "audio_config"
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.downloadURL = try container.decodeIfPresent(URL.self, forKey: .downloadURL)
    self.downloadAudioURL = try container.decodeIfPresent(URL.self, forKey: .downloadAudioURL)
    self.fileSize = try container.decodeIfPresent(Int.self, forKey: .fileSize)
    self.sessionId = try container.decodeIfPresent(UUID.self, forKey: .sessionId)
    self.outputFileName = try container.decodeIfPresent(String.self, forKey: .outputFileName)
    self.status = try container.decode(Status.self, forKey: .status)
    self.storageConfig = try container.decodeIfPresent(
      RecordConfig.StorageConfig.self, forKey: .storageConfig)
    self.videoConfig = try container.decodeIfPresent(
      RecordConfig.VideoConfig.self, forKey: .videoConfig)
    self.audioConfig = try container.decodeIfPresent(
      RecordConfig.AudioConfig.self, forKey: .audioConfig)

    if let dateString = try container.decodeIfPresent(String.self, forKey: .downloadURLExpiry) {
      self.downloadURLExpiry = try Date(dateString, strategy: .iso8601WithFractionalSeconds)
    }
    if let dateString = try container.decodeIfPresent(String.self, forKey: .invokedTime) {
      self.invokedTime = try Date(dateString, strategy: .iso8601WithFractionalSeconds)
    }
    if let dateString = try container.decodeIfPresent(String.self, forKey: .startedTime) {
      self.startedTime = try Date(dateString, strategy: .iso8601WithFractionalSeconds)
    }
    if let dateString = try container.decodeIfPresent(String.self, forKey: .stoppedTime) {
      self.stoppedTime = try Date(dateString, strategy: .iso8601WithFractionalSeconds)
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encodeIfPresent(self.downloadURL, forKey: .downloadURL)
    try container.encodeIfPresent(self.downloadAudioURL, forKey: .downloadAudioURL)
    try container.encodeIfPresent(self.fileSize, forKey: .fileSize)
    try container.encodeIfPresent(self.sessionId, forKey: .sessionId)
    try container.encodeIfPresent(self.outputFileName, forKey: .outputFileName)
    try container.encode(self.status, forKey: .status)
    try container.encodeIfPresent(self.storageConfig, forKey: .storageConfig)
    try container.encodeIfPresent(self.videoConfig, forKey: .videoConfig)
    try container.encodeIfPresent(self.audioConfig, forKey: .audioConfig)

    if let date = self.downloadURLExpiry {
      try container.encode(
        date.formatted(.iso8601WithFractionalSeconds), forKey: .downloadURLExpiry)
    }
    if let date = self.invokedTime {
      try container.encode(date.formatted(.iso8601WithFractionalSeconds), forKey: .invokedTime)
    }
    if let date = self.startedTime {
      try container.encode(date.formatted(.iso8601WithFractionalSeconds), forKey: .startedTime)
    }
    if let date = self.stoppedTime {
      try container.encode(date.formatted(.iso8601WithFractionalSeconds), forKey: .stoppedTime)
    }
  }
}

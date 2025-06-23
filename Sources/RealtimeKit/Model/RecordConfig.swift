import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct RecordConfig: Codable, Sendable {
  /// Specifies the maximum duration for recording in seconds, ranging from a minimum of 60 seconds to a maximum of 24 hours.
  /// 60 <= x <= 86400
  public var maxSeconds: Int? = nil
  /// Adds a prefix to the beginning of the file name of the recording.
  public var fileNamePrefix: String? = nil
  public var videoConfig: VideoConfig = VideoConfig()
  public var audioConfig: AudioConfig = AudioConfig()
  public var storageConfig: StorageConfig? = nil
  public var realtimeKitBucketConfig: RealtimeKitBucketConfig? = nil
  public var liveStreamingConfig: LiveStreamingConfig? = nil
  
  public enum CodingKeys: String, CodingKey {
    case maxSeconds = "max_seconds"
    case fileNamePrefix = "file_name_prefix"
    case videoConfig = "video_config"
    case audioConfig = "audio_config"
    case storageConfig = "storage_config"
    case realtimeKitBucketConfig = "realtimekit_bucket_config"
    case liveStreamingConfig = "live_streaming_config"
  }
}

extension RecordConfig {
  @MemberwiseInit(.public)
  public struct VideoConfig: Codable, Sendable {
    /// Codec using which the recording will be encoded.
    public var codec: Codec = .h264
    /// Width of the recording video in pixels.
    /// 1 <= x <= 1920
    public var width: Int = 1280
    /// Height of the recording video in pixels.
    /// 1 <= x <= 1920
    public var height: Int = 720
    /// Watermark to be added to the recording.
    public var watermark: Watermask? = nil
    /// Controls whether to export video file seperately
    public var exportFile: Bool = true
    
    private enum CodingKeys: String, CodingKey {
      case codec
      case width
      case height
      case watermark
      case exportFile = "export_file"
    }
    
    @MemberwiseInit(.public)
    public struct Watermask: Codable, Sendable {
      /// URL of the watermark image.
      public var url: URL
      /// Size of the watermark.
      public var size: CGSize?
      /// Position of the watermark.∫
      public var position: Position = .leftTop
    }
    
    public enum Codec: String, Codable, Sendable {
      case h264 = "H264"
      case vp8 = "VP8"
    }
    
    public enum Position: String, Codable, Sendable {
      case leftTop
      case rightTop
      case leftBottom
      case rightBottom
    }
  }
  
  @MemberwiseInit(.public)
  public struct AudioConfig: Codable, Sendable {
    /// Codec using which the recording will be encoded. If VP8/VP9 is selected for videoConfig, changing audioConfig is not allowed. In this case, the codec in the audioConfig is automatically set to vorbis.
    public var codec: Codec = .acc
    /// Audio signal pathway within an audio file that carries a specific sound source.
    public var channel: Channel = .stereo
    /// Controls whether to export audio file seperately
    public var exportFile: Bool = true
    
    enum CodingKeys: String, CodingKey {
      case codec
      case channel
      case exportFile = "export_file"
    }
    
    public enum Codec: String, Codable, Sendable {
      case acc = "AAC"
      case mp3 = "MP3"
    }
    
    public enum Channel: String, Codable, Sendable {
      case mono
      case stereo
    }
  }
  
  @MemberwiseInit(.public)
  public struct StorageConfig: Codable, Sendable {
    public var type: StorageType
    /// Access key of the storage medium. Access key is not required for the gcs storage media type.
    /// Note that this field is not readable by clients, only writeable.
    public var accessKey: String?
    /// Secret key of the storage medium. Similar to access_key, it is only writeable by clients, not readable.
    public var secret: String?
    /// Name of the storage medium's bucket.
    public var bucket: String?
    /// Region of the storage medium.
    public var region: String?
    /// Path relative to the bucket root at which the recording will be placed.
    public var path: String?
    /// Authentication method used for "sftp" type storage medium
    public var authMethod: AuthMethod?
    /// SSH destination server username for SFTP type storage medium
    public var username: String?
    /// SSH destination server password for SFTP type storage medium when auth_method is "PASSWORD". If auth_method is "KEY", this specifies the password for the ssh private key.
    public var password: String?
    /// SSH destination server host for SFTP type storage medium
    public var host: String?
    /// SSH destination server port for SFTP type storage medium
    public var port: Int?
    /// Private key used to login to destination SSH server for SFTP type storage medium, when auth_method used is "KEY"
    public var privateKey: String?
    
    enum CodingKeys: String, CodingKey {
      case type
      case accessKey = "access_key"
      case secret
      case bucket
      case region
      case path
      case authMethod = "auth_method"
      case username
      case password
      case host
      case port
      case privateKey = "private_key"
    }
    
    public enum StorageType: String, Codable, Sendable {
      case aws
      case azure
      case digitalOcean
      case gcs
      case sftp
    }
    
    public enum AuthMethod: String, Codable, Sendable {
      case key = "KEY"
      case password = "PASSWORD"
    }
  }
  
  @MemberwiseInit(.public)
  public struct RealtimeKitBucketConfig: Codable, Sendable {
    public var enabled: Bool
  }
  
  @MemberwiseInit(.public)
  public struct LiveStreamingConfig: Codable, Sendable {
    public var rtmpURL: URL
    
    enum CodingKeys: String, CodingKey {
      case rtmpURL = "rtmp_url"
    }
  }
}


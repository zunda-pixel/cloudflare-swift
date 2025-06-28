import Foundation
import MemberwiseInit

extension Session {
  @MemberwiseInit(.public)
  public struct User: Codable, Sendable, Identifiable, Hashable {
    public var id: UUID
    public var userId: UUID
    public var customParticipantId: String
    public var displayName: String
    public var preset: Preset?
    public var joinedAt: Date
    public var leftAt: Date
    public var duration: TimeInterval
    public var createdAt: Date
    public var updatedAt: Date
    public var peerStats: PeerStats?
   
    private enum CodingKeys: String, CodingKey {
      case id
      case userId = "user_id"
      case customParticipantId = "custom_participant_id"
      case displayName = "display_name"
      case preset = "preset_name"
      case joinedAt = "joined_at"
      case leftAt = "left_at"
      case duration
      case createdAt = "created_at"
      case updatedAt = "updated_at"
      case peerStats = "peer_stats"
    }
    
    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.id = try container.decode(UUID.self, forKey: .id)
      self.userId = try container.decode(UUID.self, forKey: .userId)
      self.customParticipantId = try container.decode(String.self, forKey: .customParticipantId)
      self.displayName = try container.decode(String.self, forKey: .displayName)
      self.preset = try container.decodeIfPresent(Preset.self, forKey: .preset)
      self.joinedAt = try Date(container.decode(String.self, forKey: .joinedAt), strategy: .iso8601WithFractionalSeconds)
      self.leftAt = try Date(container.decode(String.self, forKey: .leftAt), strategy: .iso8601WithFractionalSeconds)
      self.duration = try container.decode(TimeInterval.self, forKey: .duration)
      self.createdAt = try Date(container.decode(String.self, forKey: .createdAt), strategy: .iso8601WithFractionalSeconds)
      self.updatedAt = try Date(container.decode(String.self, forKey: .updatedAt), strategy: .iso8601WithFractionalSeconds)
      self.peerStats = try container.decodeIfPresent(PeerStats.self, forKey: .peerStats)
    }
    
    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(self.id, forKey: .id)
      try container.encode(self.userId, forKey: .userId)
      try container.encode(self.customParticipantId, forKey: .customParticipantId)
      try container.encode(self.displayName, forKey: .displayName)
      try container.encodeIfPresent(self.preset, forKey: .preset)
      try container.encode(self.joinedAt.formatted(.iso8601WithFractionalSeconds), forKey: .joinedAt)
      try container.encode(self.leftAt.formatted(.iso8601WithFractionalSeconds), forKey: .leftAt)
      try container.encode(self.duration, forKey: .duration)
      try container.encode(self.createdAt.formatted(.iso8601WithFractionalSeconds), forKey: .createdAt)
      try container.encode(self.updatedAt.formatted(.iso8601WithFractionalSeconds), forKey: .updatedAt)
      try container.encodeIfPresent(self.peerStats, forKey: .peerStats)
    }
    
    @MemberwiseInit(.public)
    public struct PeerStats: Codable, Sendable, Hashable {
      public var config: String?
      public var status: String?
      public var deviceInformation: DeviceInformation
      public var events: [Event]
      public var ipInformation: IPInformation
      public var precallNetworkInformation: PrecallNetwokInformation
      
      private enum CodingKeys: String, CodingKey {
        case config
        case status
        case deviceInformation = "device_info"
        case events
        case ipInformation = "ip_information"
        case precallNetworkInformation = "precall_network_information"
      }
      
      @MemberwiseInit(.public)
      public struct DeviceInformation: Codable, Sendable, Hashable {
        public var browser: String
        public var browserVersion: String
        public var cpus: Int
        public var engine: String
        public var isMobile: Bool
        public var memory: Int?
        public var os: String
        public var osVersion: String
        public var sdKName: String
        public var sdkVersion: String
        public var userAgent: String
        public var webGLSupport: String?
        
        private enum CodingKeys: String, CodingKey {
          case browser
          case browserVersion = "browser_version"
          case cpus
          case engine
          case isMobile = "is_mobile"
          case memory
          case os
          case osVersion = "os_version"
          case sdKName = "sdk_name"
          case sdkVersion = "sdk_version"
          case userAgent = "user_agent"
          case webGLSupport = "webgl_support"
        }
      }
      
      @MemberwiseInit(.public)
      public struct Event: Codable, Sendable, Hashable {
        public var type: EventType
        public var timestamp: Date
        public var metadata: Metadata?
        
        public enum EventType: String, Codable, Sendable, Hashable {
          case audioOn = "audio_on"
          case videoOn = "video_on"
          case mediaPermission = "media_permission"
          case selectedCameraUpdate = "selected_camera_update"
          case selectedMicrophoneUpdate = "selected_microphone_update"
          case selectedSpeakerUpdate = "selected_speaker_update"
          case audioDevicesUpdates = "audio_devices_updates"
          case videoDevicesUpdates = "video_devices_updates"
          case speakerDevicesUpdates = "speaker_devices_updates"
          case precallBegin = "precall_begin"
          case precallEnd = "precall_end"
          case videoOff = "video_off"
          case callJoin = "call_join"
          case audioOfff = "audio_off"
          case screeenshareStartRequested = "screenshare_start_requested"
          case tabChange = "tab_change"
          case browserBackground = "browser_backgrounded"
          case screenshareStarted = "screenshare_started"
          case browserForegrounded = "browser_foregrounded"
          case screenshareStopped = "screenshare_stopped"
          case disconnect
        }
        
        private enum CodingKeys: CodingKey {
          case type
          case timestamp
          case metadata
        }
        
        public init(from decoder: any Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          self.type = try container.decode(EventType.self, forKey: .type)
          self.timestamp = try Date(container.decode(String.self, forKey: .timestamp), strategy: .iso8601WithFractionalSeconds)
          self.metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
        }
        
        public func encode(to encoder: any Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(self.type, forKey: .type)
          try container.encode(self.timestamp.formatted(.iso8601WithFractionalSeconds), forKey: .timestamp)
          try container.encodeIfPresent(self.metadata, forKey: .metadata)
        }
        
        @MemberwiseInit(.public)
        public struct Metadata: Codable, Sendable, Hashable {
          public var deviceType: String?
          public var permission: String?
          public var device: Device?
          
          private enum CodingKeys: String, CodingKey {
            case deviceType = "device_type"
            case permission
            case device
          }
          
          @MemberwiseInit(.public)
          public struct Device: Codable, Sendable, Hashable {
            public var deviceId: String
            public var kind: String
            public var label: String
            public var groupId: String
            
            private enum CodingKeys: String, CodingKey {
              case deviceId = "device_id"
              case kind
              case label
              case groupId = "group_id"
            }
          }
        }
      }
      
      @MemberwiseInit(.public)
      public struct IPInformation: Codable, Sendable, Hashable {
        public var city: String
        public var country: String
        public var ipLocation: String
        public var ipv4: String
        public var org: String
        public var portal: String?
        public var region: String
        public var timezone: String
        
        private enum CodingKeys: String, CodingKey {
          case city
          case country
          case ipLocation = "ip_location"
          case ipv4
          case org
          case portal
          case region
          case timezone
        }
      }
      
      @MemberwiseInit(.public)
      public struct PrecallNetwokInformation: Codable, Sendable, Hashable {
        public var backendRTT: Int?
        public var turnConnectivity: Bool?
        public var effectiveNetworkType: String
        public var throughput: Int?
        public var jitter: Int?
        public var rtt: Int?
        public var reflexiveConnectivity: Bool?
        public var relayConnectivity: Bool?
        public var fractionalLoss: Int?
        
        private enum CodingKeys: String, CodingKey {
          case backendRTT = "backend_rtt"
          case turnConnectivity = "turn_connectivity"
          case effectiveNetworkType = "effective_networktype"
          case throughput
          case jitter
          case rtt
          case reflexiveConnectivity = "reflexive_connectivity"
          case relayConnectivity = "relay_connectivity"
          case fractionalLoss = "fractional_loss"
        }
      }
    }
  }
}

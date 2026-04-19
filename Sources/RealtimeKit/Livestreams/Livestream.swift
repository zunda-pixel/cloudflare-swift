import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Livestream: Codable, Sendable, Identifiable {
  public var id: UUID
  public var name: String
  public var status: Status
  public var meetingId: UUID?
  public var ingestServer: String?
  public var streamKey: String?
  public var playbackURL: String?
  public var ingestSeconds: Double?
  public var viewerSeconds: Double?

  public enum Status: String, Codable, Sendable, Hashable {
    case live = "LIVE"
    case offline = "OFFLINE"
    case idle = "IDLE"
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case status
    case meetingId = "meeting_id"
    case ingestServer = "ingest_server"
    case streamKey = "stream_key"
    case playbackURL = "playback_url"
    case ingestSeconds = "ingest_seconds"
    case viewerSeconds = "viewer_seconds"
  }
}

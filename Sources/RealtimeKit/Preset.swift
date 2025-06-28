import Foundation
import MemberwiseInit

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

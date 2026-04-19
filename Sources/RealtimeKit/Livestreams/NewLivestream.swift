import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct NewLivestream: Encodable, Sendable {
  public var name: String
}

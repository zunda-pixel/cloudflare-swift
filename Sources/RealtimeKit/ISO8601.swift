import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension ParseStrategy where Self == Date.ISO8601FormatStyle {
  public static var iso8601WithFractionalSeconds: Date.ISO8601FormatStyle {
    Date.ISO8601FormatStyle(includingFractionalSeconds: true)
  }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FormatStyle where Self == Date.ISO8601FormatStyle {
  public static var iso8601WithFractionalSeconds: Date.ISO8601FormatStyle {
    Date.ISO8601FormatStyle(includingFractionalSeconds: true)
  }
}

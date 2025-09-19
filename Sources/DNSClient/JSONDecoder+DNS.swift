import Foundation

extension JSONDecoder {
  /// JSON decoder configured for DNS API responses
  static let dns: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      return try Date(
        string,
        strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)
      )
    }

    return decoder
  }()
}

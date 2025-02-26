import Foundation

extension JSONDecoder {
  static let images: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      let dateFormatStyle: Date.ISO8601FormatStyle = .iso8601.year().month().day().time(includingFractionalSeconds: true)
      return try Date(string, strategy: dateFormatStyle)
    }

    return decoder
  }()
}

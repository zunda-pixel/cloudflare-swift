import Foundation

extension JSONDecoder {
  static let images: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      return try Date(
        string,
        strategy: .iso8601.year().month().day().time(includingFractionalSeconds: true)
      )
    }

    return decoder
  }()
}

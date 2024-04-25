import Foundation

extension JSONDecoder {
  static let images: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions.insert(.withFractionalSeconds)
      
      return formatter.date(from: string)!
    }
    
    return decoder
  }()
}

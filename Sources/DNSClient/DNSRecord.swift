import Foundation

/// Protocol that all DNS record types must conform to
public protocol DNSRecordProtocol: Sendable, Codable, Hashable {
  /// Unique identifier for the DNS record
  var id: String? { get }

  /// Zone identifier where the record belongs
  var zoneId: String? { get }

  /// Zone name where the record belongs
  var zoneName: String? { get }

  /// DNS record name (e.g., "example.com" or "www.example.com")
  var name: String { get }

  /// Type of DNS record (A, AAAA, CNAME, etc.)
  var type: DNSRecordType { get }

  /// Time to live for the DNS record
  var ttl: TTL { get }

  /// Whether this record can be proxied through Cloudflare
  var proxiable: Bool? { get }

  /// Whether this record is currently proxied through Cloudflare
  var proxied: Bool? { get }

  /// Whether this record is locked from editing
  var locked: Bool? { get }

  /// Optional comment for the DNS record
  var comment: String? { get }

  /// Tags associated with the DNS record
  var tags: [String]? { get }

  /// When the record was created
  var createdOn: Date? { get }

  /// When the record was last modified
  var modifiedOn: Date? { get }
}

/// Time to live configuration for DNS records
public enum TTL: Sendable, Codable, Hashable {
  /// Automatic TTL managed by Cloudflare
  case automatic

  /// Specific TTL in seconds (must be between 60-86400)
  case seconds(Int)

  /// The actual TTL value to use in API calls
  public var value: Int {
    switch self {
    case .automatic:
      return 1
    case .seconds(let value):
      return value
    }
  }

  /// Initialize from an integer value
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(Int.self)

    if value == 1 {
      self = .automatic
    } else {
      self = .seconds(value)
    }
  }

  /// Encode to integer value
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }

  /// Validate TTL value is within acceptable range
  public var isValid: Bool {
    switch self {
    case .automatic:
      return true
    case .seconds(let value):
      return value >= 60 && value <= 86400
    }
  }
}

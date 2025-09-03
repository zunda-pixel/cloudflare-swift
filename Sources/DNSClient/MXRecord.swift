import Foundation

/// MX DNS record that specifies mail exchange servers for a domain
public struct MXRecord: DNSRecordProtocol {
  /// Unique identifier for the DNS record
  public let id: String?

  /// Zone identifier where the record belongs
  public let zoneId: String?

  /// Zone name where the record belongs
  public let zoneName: String?

  /// DNS record name (e.g., "example.com" or "mail.example.com")
  public let name: String

  /// Type of DNS record - always .mx for MXRecord
  public let type: DNSRecordType = .mx

  /// Mail server hostname content of the MX record
  public let content: String

  /// Priority of the mail server (lower values have higher priority)
  public let priority: Int

  /// Structured data containing priority and target information
  public let data: MXData?

  /// Time to live for the DNS record
  public let ttl: TTL

  /// Whether this record can be proxied through Cloudflare (always false for MX)
  public let proxiable: Bool? = false

  /// Whether this record is currently proxied through Cloudflare (always false for MX)
  public let proxied: Bool? = false

  /// Whether this record is locked from editing
  public let locked: Bool?

  /// Optional comment for the DNS record
  public let comment: String?

  /// Tags associated with the DNS record
  public let tags: [String]?

  /// When the record was created
  public let createdOn: Date?

  /// When the record was last modified
  public let modifiedOn: Date?

  /// Initialize a new MX record
  /// - Parameters:
  ///   - id: Unique identifier (nil for new records)
  ///   - zoneId: Zone identifier
  ///   - zoneName: Zone name
  ///   - name: Record name
  ///   - content: Mail server hostname
  ///   - priority: Mail server priority (0-65535)
  ///   - data: Structured MX data
  ///   - ttl: Time to live
  ///   - locked: Whether record is locked
  ///   - comment: Optional comment
  ///   - tags: Associated tags
  ///   - createdOn: Creation date
  ///   - modifiedOn: Last modification date
  public init(
    id: String? = nil,
    zoneId: String? = nil,
    zoneName: String? = nil,
    name: String,
    content: String,
    priority: Int,
    data: MXData? = nil,
    ttl: TTL,
    locked: Bool? = nil,
    comment: String? = nil,
    tags: [String]? = nil,
    createdOn: Date? = nil,
    modifiedOn: Date? = nil
  ) {
    self.id = id
    self.zoneId = zoneId
    self.zoneName = zoneName
    self.name = name
    self.content = content
    self.priority = priority
    self.data = data ?? MXData(priority: priority, target: content)
    self.ttl = ttl
    self.locked = locked
    self.comment = comment
    self.tags = tags
    self.createdOn = createdOn
    self.modifiedOn = modifiedOn
  }

  /// Validate that the priority is within valid range (0-65535)
  public var isValidPriority: Bool {
    return priority >= 0 && priority <= 65535
  }

  /// Validate that the content is a valid hostname
  public var isValidHostname: Bool {
    return MXRecord.isValidHostname(content)
  }

  /// Validate hostname format
  /// - Parameter hostname: The hostname string to validate
  /// - Returns: true if the hostname is valid
  public static func isValidHostname(_ hostname: String) -> Bool {
    // Basic hostname validation
    guard !hostname.isEmpty else { return false }
    guard hostname.count <= 253 else { return false }

    // Cannot start or end with dot
    guard !hostname.hasPrefix(".") && !hostname.hasSuffix(".") else { return false }

    // Cannot contain consecutive dots
    guard !hostname.contains("..") else { return false }

    // Check for valid characters and structure
    let components = hostname.split(separator: ".")
    guard !components.isEmpty else { return false }

    for component in components {
      guard !component.isEmpty else { return false }
      guard component.count <= 63 else { return false }

      // Must start and end with alphanumeric
      guard component.first?.isLetter == true || component.first?.isNumber == true else {
        return false
      }
      guard component.last?.isLetter == true || component.last?.isNumber == true else {
        return false
      }

      // Can only contain letters, numbers, and hyphens
      for char in component {
        guard char.isLetter || char.isNumber || char == "-" else { return false }
      }
    }

    return true
  }
}

/// Structured data for MX records containing priority and target information
public struct MXData: Sendable, Codable, Hashable {
  /// Priority of the mail server (lower values have higher priority)
  public let priority: Int

  /// Target mail server hostname
  public let target: String

  /// Initialize MX data
  /// - Parameters:
  ///   - priority: Mail server priority (0-65535)
  ///   - target: Target mail server hostname
  public init(priority: Int, target: String) {
    self.priority = priority
    self.target = target
  }

  /// Validate that the priority is within valid range
  public var isValidPriority: Bool {
    return priority >= 0 && priority <= 65535
  }

  /// Validate that the target is a valid hostname
  public var isValidTarget: Bool {
    return MXRecord.isValidHostname(target)
  }
}

// MARK: - Codable Implementation

extension MXRecord {
  private enum CodingKeys: String, CodingKey {
    case id
    case zoneId = "zone_id"
    case zoneName = "zone_name"
    case name
    case type
    case content
    case priority
    case data
    case ttl
    case proxiable
    case proxied
    case locked
    case comment
    case tags
    case createdOn = "created_on"
    case modifiedOn = "modified_on"
  }
}

extension MXData {
  private enum CodingKeys: String, CodingKey {
    case priority
    case target
  }
}

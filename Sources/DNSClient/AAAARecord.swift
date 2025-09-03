import Foundation

/// A DNS record that maps a domain name to an IPv6 address
public struct AAAARecord: DNSRecordProtocol {
  /// Unique identifier for the DNS record
  public let id: String?

  /// Zone identifier where the record belongs
  public let zoneId: String?

  /// Zone name where the record belongs
  public let zoneName: String?

  /// DNS record name (e.g., "example.com" or "www.example.com")
  public let name: String

  /// Type of DNS record - always .aaaa for AAAARecord
  public let type: DNSRecordType = .aaaa

  /// IPv6 address content of the AAAA record
  public let content: String

  /// Time to live for the DNS record
  public let ttl: TTL

  /// Whether this record can be proxied through Cloudflare
  public let proxiable: Bool?

  /// Whether this record is currently proxied through Cloudflare
  public let proxied: Bool?

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

  /// Initialize a new AAAA record
  /// - Parameters:
  ///   - id: Unique identifier (nil for new records)
  ///   - zoneId: Zone identifier
  ///   - zoneName: Zone name
  ///   - name: Record name
  ///   - content: IPv6 address
  ///   - ttl: Time to live
  ///   - proxiable: Whether record can be proxied
  ///   - proxied: Whether record is proxied
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
    ttl: TTL,
    proxiable: Bool? = nil,
    proxied: Bool? = nil,
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
    self.ttl = ttl
    self.proxiable = proxiable
    self.proxied = proxied
    self.locked = locked
    self.comment = comment
    self.tags = tags
    self.createdOn = createdOn
    self.modifiedOn = modifiedOn
  }

  /// Validate that the content is a valid IPv6 address
  public var isValidIPv6: Bool {
    return AAAARecord.isValidIPv6Address(content)
  }

  /// Validate IPv6 address format
  /// - Parameter address: The IPv6 address string to validate
  /// - Returns: true if the address is a valid IPv6 format
  public static func isValidIPv6Address(_ address: String) -> Bool {
    // Handle compressed notation (::)
    let doubleColonCount = address.components(separatedBy: "::").count - 1

    // Can have at most one "::" in a valid IPv6 address
    guard doubleColonCount <= 1 else { return false }

    // Split by "::" to handle compressed notation
    var parts: [String]
    if doubleColonCount == 1 {
      parts = address.components(separatedBy: "::")
      // Handle cases like "::1" or "2001:db8::"
      if parts.count == 2 {
        let leftPart = parts[0].isEmpty ? [] : parts[0].components(separatedBy: ":")
        let rightPart = parts[1].isEmpty ? [] : parts[1].components(separatedBy: ":")

        // Total groups should not exceed 8, and compressed section should fill the gap
        let totalGroups = leftPart.count + rightPart.count
        guard totalGroups < 8 else { return false }

        // Validate each group
        for group in leftPart + rightPart {
          guard isValidIPv6Group(group) else { return false }
        }
        return true
      }
    } else {
      // No compression, should have exactly 8 groups
      parts = address.components(separatedBy: ":")
      guard parts.count == 8 else { return false }

      // Validate each group
      for group in parts {
        guard isValidIPv6Group(group) else { return false }
      }
      return true
    }

    return false
  }

  /// Validate a single IPv6 group (hexadecimal, 1-4 characters)
  /// - Parameter group: The group string to validate
  /// - Returns: true if the group is valid
  private static func isValidIPv6Group(_ group: String) -> Bool {
    // Empty groups are not allowed (except in compressed notation which is handled separately)
    guard !group.isEmpty else { return false }

    // Group should be 1-4 hexadecimal characters
    guard group.count <= 4 else { return false }

    // Check if all characters are valid hexadecimal
    let hexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    return group.unicodeScalars.allSatisfy { hexCharacterSet.contains($0) }
  }
}

// MARK: - Codable Implementation

extension AAAARecord {
  private enum CodingKeys: String, CodingKey {
    case id
    case zoneId = "zone_id"
    case zoneName = "zone_name"
    case name
    case type
    case content
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

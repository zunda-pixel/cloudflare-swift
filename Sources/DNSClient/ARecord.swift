import Foundation

/// A DNS record that maps a domain name to an IPv4 address
public struct ARecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?
    
    /// Zone identifier where the record belongs
    public let zoneId: String?
    
    /// Zone name where the record belongs
    public let zoneName: String?
    
    /// DNS record name (e.g., "example.com" or "www.example.com")
    public let name: String
    
    /// Type of DNS record - always .a for ARecord
    public let type: DNSRecordType = .a
    
    /// IPv4 address content of the A record
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
    
    /// Initialize a new A record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name
    ///   - content: IPv4 address
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
    
    /// Validate that the content is a valid IPv4 address
    public var isValidIPv4: Bool {
        return ARecord.isValidIPv4Address(content)
    }
    
    /// Validate IPv4 address format
    /// - Parameter address: The IPv4 address string to validate
    /// - Returns: true if the address is a valid IPv4 format
    public static func isValidIPv4Address(_ address: String) -> Bool {
        let components = address.split(separator: ".")
        
        // IPv4 must have exactly 4 components
        guard components.count == 4 else { return false }
        
        // Each component must be a valid integer between 0-255
        for component in components {
            guard let number = Int(component),
                  number >= 0,
                  number <= 255,
                  String(number) == component else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Codable Implementation

extension ARecord {
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
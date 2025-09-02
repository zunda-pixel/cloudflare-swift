import Foundation

/// A DNS record that maps an alias name to a canonical domain name
public struct CNAMERecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?
    
    /// Zone identifier where the record belongs
    public let zoneId: String?
    
    /// Zone name where the record belongs
    public let zoneName: String?
    
    /// DNS record name (e.g., "www.example.com" - the alias)
    public let name: String
    
    /// Type of DNS record - always .cname for CNAMERecord
    public let type: DNSRecordType = .cname
    
    /// Target domain name that this alias points to
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
    
    /// Initialize a new CNAME record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name (the alias)
    ///   - content: Target domain name
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
    
    /// Validate that the content is a valid domain name
    public var isValidDomainName: Bool {
        return CNAMERecord.isValidDomainName(content)
    }
    
    /// Validate domain name format according to RFC standards
    /// - Parameter domain: The domain name string to validate
    /// - Returns: true if the domain name is valid
    public static func isValidDomainName(_ domain: String) -> Bool {
        // Empty domain is not valid
        guard !domain.isEmpty else { return false }
        
        // Domain cannot be longer than 253 characters
        guard domain.count <= 253 else { return false }
        
        // Check if it's an IPv4 address (not valid for domain names)
        if isIPv4Address(domain) { return false }
        
        // Check if it's an IPv6 address (not valid for domain names)
        if isIPv6Address(domain) { return false }
        
        // Remove trailing dot if present (FQDN format)
        let normalizedDomain = domain.hasSuffix(".") ? String(domain.dropLast()) : domain
        
        // Split into labels
        let labels = normalizedDomain.components(separatedBy: ".")
        
        // Must have at least one label
        guard !labels.isEmpty else { return false }
        
        // Validate each label
        for label in labels {
            guard isValidDomainLabel(label) else { return false }
        }
        
        return true
    }
    
    /// Validate a single domain label
    /// - Parameter label: The domain label to validate
    /// - Returns: true if the label is valid
    private static func isValidDomainLabel(_ label: String) -> Bool {
        // Label cannot be empty
        guard !label.isEmpty else { return false }
        
        // Label cannot be longer than 63 characters
        guard label.count <= 63 else { return false }
        
        // Label cannot start or end with hyphen
        guard !label.hasPrefix("-") && !label.hasSuffix("-") else { return false }
        
        // Label can only contain alphanumeric characters and hyphens
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
        return label.unicodeScalars.allSatisfy { allowedCharacterSet.contains($0) }
    }
    
    /// Check if a string is an IPv4 address
    /// - Parameter address: The string to check
    /// - Returns: true if it's a valid IPv4 address
    private static func isIPv4Address(_ address: String) -> Bool {
        let components = address.split(separator: ".")
        guard components.count == 4 else { return false }
        
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
    
    /// Check if a string is an IPv6 address
    /// - Parameter address: The string to check
    /// - Returns: true if it's a valid IPv6 address
    private static func isIPv6Address(_ address: String) -> Bool {
        // Simple check for IPv6 - contains colons and hex characters
        return address.contains(":") && 
               address.unicodeScalars.allSatisfy { 
                   CharacterSet(charactersIn: "0123456789abcdefABCDEF:").contains($0) 
               }
    }
}

// MARK: - Codable Implementation

extension CNAMERecord {
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
import Foundation

/// NS DNS record that specifies the authoritative name servers for a domain
public struct NSRecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?
    
    /// Zone identifier where the record belongs
    public let zoneId: String?
    
    /// Zone name where the record belongs
    public let zoneName: String?
    
    /// DNS record name (e.g., "example.com" or "subdomain.example.com")
    public let name: String
    
    /// Type of DNS record - always .ns for NSRecord
    public let type: DNSRecordType = .ns
    
    /// Name server hostname content of the NS record
    public let content: String
    
    /// Time to live for the DNS record
    public let ttl: TTL
    
    /// Whether this record can be proxied through Cloudflare (always false for NS)
    public let proxiable: Bool? = false
    
    /// Whether this record is currently proxied through Cloudflare (always false for NS)
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
 
    /// Initialize a new NS record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name
    ///   - content: Name server hostname
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
        self.ttl = ttl
        self.locked = locked
        self.comment = comment
        self.tags = tags
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
    }
    
    /// Validate that the content is a valid name server hostname
    public var isValidNameServer: Bool {
        return NSRecord.isValidNameServer(content)
    }
    
    /// Validate hostname format (alias for name server validation)
    /// - Parameter hostname: The hostname to validate
    /// - Returns: true if the hostname is valid
    public static func isValidHostname(_ hostname: String) -> Bool {
        return isValidNameServer(hostname)
    }
    
    /// Validate name server hostname format
    /// - Parameter nameServer: The name server hostname to validate
    /// - Returns: true if the name server hostname is valid
    public static func isValidNameServer(_ nameServer: String) -> Bool {
        // Name servers must be valid hostnames
        guard !nameServer.isEmpty else { return false }
        guard nameServer.count <= 253 else { return false }
        
        // Cannot start or end with dot (except for FQDN ending with single dot)
        let hostname = nameServer.hasSuffix(".") ? String(nameServer.dropLast()) : nameServer
        guard !hostname.hasPrefix(".") else { return false }
        
        // Cannot contain consecutive dots
        guard !hostname.contains("..") else { return false }
        
        // Check for valid characters and structure
        let components = hostname.split(separator: ".")
        guard !components.isEmpty else { return false }
        
        for component in components {
            guard !component.isEmpty else { return false }
            guard component.count <= 63 else { return false }
            
            // Must start and end with alphanumeric
            guard component.first?.isLetter == true || component.first?.isNumber == true else { return false }
            guard component.last?.isLetter == true || component.last?.isNumber == true else { return false }
            
            // Can only contain letters, numbers, and hyphens
            for char in component {
                guard char.isLetter || char.isNumber || char == "-" else { return false }
            }
        }
        
        return true
    }
    
    /// Check if this is a fully qualified domain name (ends with dot)
    public var isFQDN: Bool {
        return content.hasSuffix(".")
    }
    
    /// Get the canonical form of the name server (with trailing dot)
    public var canonicalNameServer: String {
        return content.hasSuffix(".") ? content : content + "."
    }
    
    /// Get the FQDN form of the content (with trailing dot)
    public var fqdnContent: String {
        return canonicalNameServer
    }
    
    /// Get the normalized form of the content (without trailing dot)
    public var normalizedContent: String {
        return content.hasSuffix(".") ? String(content.dropLast()) : content
    }
}

// MARK: - Codable Implementation

extension NSRecord {
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
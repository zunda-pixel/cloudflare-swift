import Foundation

/// CAA DNS record that specifies which certificate authorities are authorized to issue certificates for a domain
public struct CAARecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?
    
    /// Zone identifier where the record belongs
    public let zoneId: String?
    
    /// Zone name where the record belongs
    public let zoneName: String?
    
    /// DNS record name (e.g., "example.com" or "subdomain.example.com")
    public let name: String
    
    /// Type of DNS record - always .caa for CAARecord
    public let type: DNSRecordType = .caa
    
    /// CAA record content in the format "flags tag value"
    public let content: String
    
    /// Flags field (0-255, typically 0 or 128 for critical)
    public let flags: Int
    
    /// Tag field specifying the property type (issue, issuewild, iodef)
    public let tag: String
    
    /// Value field containing the property value
    public let value: String
    
    /// Structured data containing flags, tag, and value information
    public let data: CAAData?
    
    /// Time to live for the DNS record
    public let ttl: TTL
    
    /// Whether this record can be proxied through Cloudflare (always false for CAA)
    public let proxiable: Bool? = false
    
    /// Whether this record is currently proxied through Cloudflare (always false for CAA)
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
    
    /// Initialize a new CAA record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name
    ///   - content: CAA record content in "flags tag value" format
    ///   - flags: CAA flags (0-255)
    ///   - tag: CAA tag (issue, issuewild, iodef)
    ///   - value: CAA value
    ///   - data: Structured CAA data
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
        flags: Int,
        tag: String,
        value: String,
        data: CAAData? = nil,
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
        self.flags = flags
        self.tag = tag
        self.value = value
        self.data = data ?? CAAData(flags: flags, tag: tag, value: value)
        self.ttl = ttl
        self.locked = locked
        self.comment = comment
        self.tags = tags
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
    }    

    /// Convenience initializer using structured data
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name
    ///   - flags: CAA flags (0-255)
    ///   - tag: CAA tag (issue, issuewild, iodef)
    ///   - value: CAA value
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
        flags: Int,
        tag: String,
        value: String,
        ttl: TTL,
        locked: Bool? = nil,
        comment: String? = nil,
        tags: [String]? = nil,
        createdOn: Date? = nil,
        modifiedOn: Date? = nil
    ) {
        let content = "\(flags) \(tag) \(value)"
        self.init(
            id: id,
            zoneId: zoneId,
            zoneName: zoneName,
            name: name,
            content: content,
            flags: flags,
            tag: tag,
            value: value,
            data: CAAData(flags: flags, tag: tag, value: value),
            ttl: ttl,
            locked: locked,
            comment: comment,
            tags: tags,
            createdOn: createdOn,
            modifiedOn: modifiedOn
        )
    }    

    /// Validate that the flags value is within valid range (0-255)
    public var isValidFlags: Bool {
        return flags >= 0 && flags <= 255
    }
    
    /// Validate that the tag is a recognized CAA tag
    public var isValidTag: Bool {
        return CAARecord.isValidTag(tag)
    }
    
    /// Validate that the value is appropriate for the tag
    public var isValidValue: Bool {
        return CAARecord.isValidValue(value, for: tag)
    }
    
    /// Validate all CAA record fields
    public var isValid: Bool {
        return isValidFlags && isValidTag && isValidValue
    }
    
    /// Check if this is a critical CAA record (flags bit 7 set)
    public var isCritical: Bool {
        return (flags & 128) != 0
    }
    
    /// Validate CAA tag
    /// - Parameter tag: The tag to validate
    /// - Returns: true if the tag is valid
    public static func isValidTag(_ tag: String) -> Bool {
        let validTags = ["issue", "issuewild", "iodef"]
        return validTags.contains(tag.lowercased())
    }
    
    /// Validate CAA tag (alternative method name for compatibility)
    /// - Parameter tag: The tag to validate
    /// - Returns: true if the tag is valid
    public static func isValidCAATag(_ tag: String) -> Bool {
        return isValidTag(tag)
    }
    
    /// Validate CAA value for a given tag (alternative method name for compatibility)
    /// - Parameters:
    ///   - value: The value to validate
    ///   - tag: The tag context for validation
    /// - Returns: true if the value is valid for the tag
    public static func isValidCAAValue(_ value: String, for tag: String) -> Bool {
        return isValidValue(value, for: tag)
    }    
 
   /// Validate CAA value for a given tag
    /// - Parameters:
    ///   - value: The value to validate
    ///   - tag: The tag context for validation
    /// - Returns: true if the value is valid for the tag
    public static func isValidValue(_ value: String, for tag: String) -> Bool {
        guard !value.isEmpty else { return false }
        
        switch tag.lowercased() {
        case "issue", "issuewild":
            // Can be ";" for no authorization, or a domain name optionally with parameters
            if value == ";" {
                return true
            }
            // Basic domain validation - more permissive for CA domains
            return isValidCADomain(value)
            
        case "iodef":
            // Should be a URL (mailto: or http:/https:) or email address
            return isValidIODEFValue(value)
            
        default:
            return false
        }
    }
    
    /// Validate CA domain name (more permissive than regular domain validation)
    /// - Parameter domain: The domain to validate
    /// - Returns: true if the domain is valid for CA purposes
    private static func isValidCADomain(_ domain: String) -> Bool {
        // Extract domain part (before any semicolon parameters)
        let domainPart = domain.split(separator: ";").first?.trimmingCharacters(in: .whitespaces) ?? ""
        
        guard !domainPart.isEmpty else { return false }
        guard domainPart.count <= 253 else { return false }
        
        // Cannot start or end with dot
        guard !domainPart.hasPrefix(".") && !domainPart.hasSuffix(".") else { return false }
        
        // Cannot contain consecutive dots
        guard !domainPart.contains("..") else { return false }
        
        // Check for valid characters and structure
        let components = domainPart.split(separator: ".")
        guard !components.isEmpty else { return false }
        
        for component in components {
            guard !component.isEmpty else { return false }
            guard component.count <= 63 else { return false }
            
            // Can contain letters, numbers, hyphens, and underscores (more permissive for CAs)
            for char in component {
                guard char.isLetter || char.isNumber || char == "-" || char == "_" else { return false }
            }
        }
        
        return true
    }   
 
    /// Validate IODEF value (URL or email)
    /// - Parameter value: The IODEF value to validate
    /// - Returns: true if the value is valid
    private static func isValidIODEFValue(_ value: String) -> Bool {
        // Check for mailto: URL
        if value.lowercased().hasPrefix("mailto:") {
            let email = String(value.dropFirst(7))
            return isValidEmail(email)
        }
        
        // Check for HTTP/HTTPS URL
        if value.lowercased().hasPrefix("http://") || value.lowercased().hasPrefix("https://") {
            return isValidURL(value)
        }
        
        // Check if it's a plain email address
        return isValidEmail(value)
    }
    
    /// Basic email validation
    /// - Parameter email: The email to validate
    /// - Returns: true if the email format is valid
    private static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    /// Basic URL validation
    /// - Parameter url: The URL to validate
    /// - Returns: true if the URL format is valid
    private static func isValidURL(_ url: String) -> Bool {
        guard let nsurl = URL(string: url) else { return false }
        return nsurl.scheme != nil && nsurl.host != nil
    }
}

/// Structured data for CAA records containing flags, tag, and value information
public struct CAAData: Sendable, Codable, Hashable {
    /// Flags field (0-255, typically 0 or 128 for critical)
    public let flags: Int
    
    /// Tag field specifying the property type (issue, issuewild, iodef)
    public let tag: String
    
    /// Value field containing the property value
    public let value: String
    
    /// Initialize CAA data
    /// - Parameters:
    ///   - flags: CAA flags (0-255)
    ///   - tag: CAA tag (issue, issuewild, iodef)
    ///   - value: CAA value
    public init(flags: Int, tag: String, value: String) {
        self.flags = flags
        self.tag = tag
        self.value = value
    }
    
    /// Validate that the flags value is within valid range
    public var isValidFlags: Bool {
        return flags >= 0 && flags <= 255
    }
    
    /// Validate that the tag is a recognized CAA tag
    public var isValidTag: Bool {
        return CAARecord.isValidTag(tag)
    }
    
    /// Validate that the value is appropriate for the tag
    public var isValidValue: Bool {
        return CAARecord.isValidValue(value, for: tag)
    }
    
    /// Validate all CAA data fields
    public var isValid: Bool {
        return isValidFlags && isValidTag && isValidValue
    }
    
    /// Check if this is a critical CAA record (flags bit 7 set)
    public var isCritical: Bool {
        return (flags & 128) != 0
    }
}

// MARK: - Codable Implementation

extension CAARecord {
    private enum CodingKeys: String, CodingKey {
        case id
        case zoneId = "zone_id"
        case zoneName = "zone_name"
        case name
        case type
        case content
        case flags
        case tag
        case value
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

extension CAAData {
    private enum CodingKeys: String, CodingKey {
        case flags
        case tag
        case value
    }
}
import Foundation

/// TXT DNS record that stores arbitrary text data
public struct TXTRecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?
    
    /// Zone identifier where the record belongs
    public let zoneId: String?
    
    /// Zone name where the record belongs
    public let zoneName: String?
    
    /// DNS record name (e.g., "example.com" or "_dmarc.example.com")
    public let name: String
    
    /// Type of DNS record - always .txt for TXTRecord
    public let type: DNSRecordType = .txt
    
    /// Text content of the TXT record
    public let content: String
    
    /// Time to live for the DNS record
    public let ttl: TTL
    
    /// Whether this record can be proxied through Cloudflare (always false for TXT)
    public let proxiable: Bool? = false
    
    /// Whether this record is currently proxied through Cloudflare (always false for TXT)
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
    
    /// Initialize a new TXT record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name
    ///   - content: Text content
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
    
    /// Validate that the content is within acceptable length limits
    public var isValidContent: Bool {
        return TXTRecord.isValidTextContent(content)
    }
    
    /// Get the content with proper quoting if needed
    public var quotedContent: String {
        return TXTRecord.quoteTextContent(content)
    }
    
    /// Get the content without quotes if it was quoted
    public var unquotedContent: String {
        return TXTRecord.unquoteTextContent(content)
    }
    
    /// Validate TXT record content
    /// - Parameter content: The text content to validate
    /// - Returns: true if the content is valid
    public static func isValidTextContent(_ content: String) -> Bool {
        // TXT records can be empty
        guard content.count <= 255 else { return false }
        
        // Content is valid if it can be represented as UTF-8
        // (Swift strings are always valid UTF-8)
        return true
    }
    
    /// Add quotes to text content if it contains spaces or special characters
    /// - Parameter content: The text content to quote
    /// - Returns: Quoted content if needed, otherwise original content
    public static func quoteTextContent(_ content: String) -> String {
        // If content is already quoted, return as-is
        if content.hasPrefix("\"") && content.hasSuffix("\"") {
            return content
        }
        
        // Quote if content contains spaces, quotes, or other special characters
        let needsQuoting = content.contains(" ") || 
                          content.contains("\"") || 
                          content.contains("\\") ||
                          content.contains("\t") ||
                          content.contains("\n") ||
                          content.contains("\r")
        
        if needsQuoting {
            // Escape existing quotes and backslashes
            let escaped = content
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
        }
        
        return content
    }
    
    /// Remove quotes from text content if it was quoted
    /// - Parameter content: The text content to unquote
    /// - Returns: Unquoted content
    public static func unquoteTextContent(_ content: String) -> String {
        // If not quoted, return as-is
        guard content.hasPrefix("\"") && content.hasSuffix("\"") && content.count >= 2 else {
            return content
        }
        
        // Remove outer quotes and unescape
        let inner = String(content.dropFirst().dropLast())
        return inner
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\\", with: "\\")
    }
    
    /// Check if content represents a structured record (like SPF, DKIM, DMARC)
    public var isStructuredRecord: Bool {
        let lowercased = content.lowercased()
        return lowercased.hasPrefix("v=spf1") ||
               lowercased.hasPrefix("v=dkim1") ||
               lowercased.hasPrefix("v=dmarc1") ||
               lowercased.hasPrefix("_domainkey") ||
               lowercased.contains("google-site-verification") ||
               lowercased.contains("facebook-domain-verification")
    }
    
    /// Get the record type based on content (SPF, DKIM, DMARC, etc.)
    public var structuredRecordType: String? {
        let lowercased = content.lowercased()
        
        if lowercased.hasPrefix("v=spf1") {
            return "SPF"
        } else if lowercased.hasPrefix("v=dkim1") {
            return "DKIM"
        } else if lowercased.hasPrefix("v=dmarc1") {
            return "DMARC"
        } else if lowercased.contains("google-site-verification") {
            return "Google Site Verification"
        } else if lowercased.contains("facebook-domain-verification") {
            return "Facebook Domain Verification"
        }
        
        return nil
    }
}

// MARK: - Codable Implementation

extension TXTRecord {
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
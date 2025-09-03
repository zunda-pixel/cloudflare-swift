import Foundation

/// PTR DNS record that maps an IP address to a domain name (reverse DNS lookup)
public struct PTRRecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?

    /// Zone identifier where the record belongs
    public let zoneId: String?

    /// Zone name where the record belongs
    public let zoneName: String?

    /// DNS record name (e.g., "1.0.0.127.in-addr.arpa" for IPv4 or reverse IPv6 format)
    public let name: String

    /// Type of DNS record - always .ptr for PTRRecord
    public let type: DNSRecordType = .ptr

    /// Target domain name content of the PTR record
    public let content: String

    /// Time to live for the DNS record
    public let ttl: TTL

    /// Whether this record can be proxied through Cloudflare (always false for PTR)
    public let proxiable: Bool? = false

    /// Whether this record is currently proxied through Cloudflare (always false for PTR)
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

    /// Initialize a new PTR record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name (reverse DNS format)
    ///   - content: Target domain name
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

    /// Validate that the content is a valid domain name
    public var isValidDomainName: Bool {
        return PTRRecord.isValidDomainName(content)
    }

    /// Validate that the content is a valid target domain name
    public var isValidTargetDomain: Bool {
        return isValidDomainName
    }

    /// Validate that the name follows reverse DNS format
    public var isValidReverseDNSName: Bool {
        return PTRRecord.isValidReverseDNSName(name)
    }

    /// Check if this PTR record is for IPv4 (in-addr.arpa)
    public var isIPv4PTR: Bool {
        return name.lowercased().hasSuffix(".in-addr.arpa")
            || name.lowercased().hasSuffix(".in-addr.arpa.")
    }

    /// Check if this PTR record is for IPv4 (in-addr.arpa) - alternative name
    public var isIPv4Reverse: Bool {
        return isIPv4PTR
    }

    /// Check if this PTR record is for IPv6 (ip6.arpa)
    public var isIPv6PTR: Bool {
        return name.lowercased().hasSuffix(".ip6.arpa") || name.lowercased().hasSuffix(".ip6.arpa.")
    }

    /// Check if this PTR record is for IPv6 (ip6.arpa) - alternative name
    public var isIPv6Reverse: Bool {
        return isIPv6PTR
    }

    /// Validate all PTR record fields
    public var isValid: Bool {
        return isValidTargetDomain && isValidReverseDNSName
    }

    /// Validate hostname format (alias for domain name validation)
    /// - Parameter hostname: The hostname to validate
    /// - Returns: true if the hostname is valid
    public static func isValidHostname(_ hostname: String) -> Bool {
        return isValidDomainName(hostname)
    }

    /// Validate domain name format
    /// - Parameter domainName: The domain name to validate
    /// - Returns: true if the domain name is valid
    public static func isValidDomainName(_ domainName: String) -> Bool {
        guard !domainName.isEmpty else { return false }
        guard domainName.count <= 253 else { return false }

        // Cannot start or end with dot (except for FQDN ending with single dot)
        let hostname = domainName.hasSuffix(".") ? String(domainName.dropLast()) : domainName
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

    /// Validate reverse DNS name format
    /// - Parameter reverseName: The reverse DNS name to validate
    /// - Returns: true if the reverse DNS name is valid
    public static func isValidReverseDNSName(_ reverseName: String) -> Bool {
        guard !reverseName.isEmpty else { return false }

        let lowercaseName = reverseName.lowercased()

        // Check for IPv4 reverse DNS format (*.in-addr.arpa)
        if lowercaseName.hasSuffix(".in-addr.arpa") || lowercaseName.hasSuffix(".in-addr.arpa.") {
            return isValidIPv4ReverseName(reverseName)
        }

        // Check for IPv6 reverse DNS format (*.ip6.arpa)
        if lowercaseName.hasSuffix(".ip6.arpa") || lowercaseName.hasSuffix(".ip6.arpa.") {
            return isValidIPv6ReverseName(reverseName)
        }

        // For other formats, they are not valid reverse DNS names
        return false
    }

    /// Validate IPv4 reverse DNS name format
    /// - Parameter reverseName: The IPv4 reverse DNS name to validate
    /// - Returns: true if the IPv4 reverse DNS name is valid
    private static func isValidIPv4ReverseName(_ reverseName: String) -> Bool {
        let lowercaseName = reverseName.lowercased()
        let suffix = ".in-addr.arpa"

        // Check for leading dot (invalid)
        if reverseName.hasPrefix(".") {
            return false
        }

        // Remove the suffix to get the IP part
        let ipPart: String
        if lowercaseName.hasSuffix(suffix + ".") {
            ipPart = String(reverseName.dropLast(suffix.count + 1))
        } else if lowercaseName.hasSuffix(suffix) {
            ipPart = String(reverseName.dropLast(suffix.count))
        } else {
            return false
        }

        // Check for empty IP part
        guard !ipPart.isEmpty else { return false }

        // Split by dots and validate each octet
        let octets = ipPart.split(separator: ".")
        guard octets.count >= 1 && octets.count <= 4 else { return false }

        for octet in octets {
            guard let number = Int(octet),
                number >= 0,
                number <= 255,
                String(number) == octet
            else {
                return false
            }
        }

        return true
    }

    /// Validate IPv6 reverse DNS name format
    /// - Parameter reverseName: The IPv6 reverse DNS name to validate
    /// - Returns: true if the IPv6 reverse DNS name is valid
    private static func isValidIPv6ReverseName(_ reverseName: String) -> Bool {
        let lowercaseName = reverseName.lowercased()
        let suffix = ".ip6.arpa"

        // Remove the suffix to get the hex part
        let hexPart: String
        if lowercaseName.hasSuffix(suffix + ".") {
            hexPart = String(reverseName.dropLast(suffix.count + 1))
        } else if lowercaseName.hasSuffix(suffix) {
            hexPart = String(reverseName.dropLast(suffix.count))
        } else {
            return false
        }

        // Split by dots and validate each hex digit
        let hexDigits = hexPart.split(separator: ".")
        guard hexDigits.count <= 32 else { return false }  // IPv6 has 32 hex digits max

        for digit in hexDigits {
            guard digit.count == 1 else { return false }
            guard digit.first?.isHexDigit == true else { return false }
        }

        return true
    }

    /// Check if this is a fully qualified domain name (ends with dot)
    public var isFQDN: Bool {
        return content.hasSuffix(".")
    }

    /// Get the canonical form of the target domain (with trailing dot)
    public var canonicalTarget: String {
        return content.hasSuffix(".") ? content : content + "."
    }

    /// Extract IP address from IPv4 reverse DNS name
    /// - Returns: The IPv4 address if this is a valid IPv4 PTR record, nil otherwise
    public var ipv4Address: String? {
        guard isIPv4PTR else { return nil }

        let lowercaseName = name.lowercased()
        let suffix = ".in-addr.arpa"

        let ipPart: String
        if lowercaseName.hasSuffix(suffix + ".") {
            ipPart = String(name.dropLast(suffix.count + 1))
        } else if lowercaseName.hasSuffix(suffix) {
            ipPart = String(name.dropLast(suffix.count))
        } else {
            return nil
        }

        // Reverse the octets to get the original IP
        let octets = ipPart.split(separator: ".").reversed()
        guard octets.count == 4 else { return nil }

        return octets.joined(separator: ".")
    }

    /// Get the FQDN form of the content (with trailing dot)
    public var fqdnContent: String {
        return canonicalTarget
    }

    /// Get the normalized form of the content (without trailing dot)
    public var normalizedContent: String {
        return content.hasSuffix(".") ? String(content.dropLast()) : content
    }

    /// Extract IP address from reverse DNS name (works for both IPv4 and IPv6)
    public var extractedIPAddress: String? {
        if isIPv4PTR {
            return ipv4Address
        } else if isIPv6PTR {
            return ipv6Address
        }
        return nil
    }

    /// Extract IPv6 address from IPv6 reverse DNS name
    /// - Returns: The IPv6 address if this is a valid full IPv6 PTR record, nil otherwise
    public var ipv6Address: String? {
        guard isIPv6PTR else { return nil }

        let lowercaseName = name.lowercased()
        let suffix = ".ip6.arpa"

        let hexPart: String
        if lowercaseName.hasSuffix(suffix + ".") {
            hexPart = String(name.dropLast(suffix.count + 1))
        } else if lowercaseName.hasSuffix(suffix) {
            hexPart = String(name.dropLast(suffix.count))
        } else {
            return nil
        }

        // Split by dots and reverse to get original order
        let hexDigits = hexPart.split(separator: ".").reversed()
        guard hexDigits.count == 32 else { return nil }  // Must be full IPv6 address

        // Group into 4-character hex groups
        let hexString = hexDigits.joined()
        var ipv6Parts: [String] = []

        for i in stride(from: 0, to: hexString.count, by: 4) {
            let startIndex = hexString.index(hexString.startIndex, offsetBy: i)
            let endIndex = hexString.index(startIndex, offsetBy: 4)
            ipv6Parts.append(String(hexString[startIndex..<endIndex]))
        }

        return ipv6Parts.joined(separator: ":")
    }
}

// MARK: - Codable Implementation

extension PTRRecord {
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

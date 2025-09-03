import Foundation

/// SRV DNS record that specifies service location information
public struct SRVRecord: DNSRecordProtocol {
    /// Unique identifier for the DNS record
    public let id: String?
    
    /// Zone identifier where the record belongs
    public let zoneId: String?
    
    /// Zone name where the record belongs
    public let zoneName: String?
    
    /// DNS record name (e.g., "_sip._tcp.example.com")
    public let name: String
    
    /// Type of DNS record - always .srv for SRVRecord
    public let type: DNSRecordType = .srv
    
    /// Target hostname for the service
    public let content: String
    
    /// Priority of the service (lower values have higher priority)
    public let priority: Int
    
    /// Weight for load balancing among services with same priority
    public let weight: Int
    
    /// Port number where the service is available
    public let port: Int
    
    /// Structured data containing priority, weight, port, and target information
    public let data: SRVData?
    
    /// Time to live for the DNS record
    public let ttl: TTL
    
    /// Whether this record can be proxied through Cloudflare (always false for SRV)
    public let proxiable: Bool? = false
    
    /// Whether this record is currently proxied through Cloudflare (always false for SRV)
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
    
    /// Initialize a new SRV record
    /// - Parameters:
    ///   - id: Unique identifier (nil for new records)
    ///   - zoneId: Zone identifier
    ///   - zoneName: Zone name
    ///   - name: Record name (should include service and protocol, e.g., "_sip._tcp.example.com")
    ///   - content: Target hostname
    ///   - priority: Service priority (0-65535)
    ///   - weight: Service weight for load balancing (0-65535)
    ///   - port: Port number (1-65535)
    ///   - data: Structured SRV data
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
        weight: Int,
        port: Int,
        data: SRVData? = nil,
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
        self.weight = weight
        self.port = port
        self.data = data ?? SRVData(priority: priority, weight: weight, port: port, target: content)
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
    
    /// Validate that the weight is within valid range (0-65535)
    public var isValidWeight: Bool {
        return weight >= 0 && weight <= 65535
    }
    
    /// Validate that the port is within valid range (1-65535)
    public var isValidPort: Bool {
        return port >= 1 && port <= 65535
    }
    
    /// Validate that the content is a valid hostname
    public var isValidTarget: Bool {
        return SRVRecord.isValidHostname(content)
    }
    
    /// Validate that the name follows SRV record naming convention
    public var isValidServiceName: Bool {
        return SRVRecord.isValidServiceName(name)
    }
    
    /// Validate all SRV record fields
    public var isValid: Bool {
        return isValidPriority && isValidWeight && isValidPort && isValidTarget && isValidServiceName
    }
    
    /// Validate hostname format
    /// - Parameter hostname: The hostname string to validate
    /// - Returns: true if the hostname is valid
    public static func isValidHostname(_ hostname: String) -> Bool {
        // Allow "." for root domain
        if hostname == "." {
            return true
        }
        
        // Basic hostname validation
        guard !hostname.isEmpty else { return false }
        guard hostname.count <= 253 else { return false }
        
        // Cannot start or end with dot (except for single dot)
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
            guard component.first?.isLetter == true || component.first?.isNumber == true else { return false }
            guard component.last?.isLetter == true || component.last?.isNumber == true else { return false }
            
            // Can only contain letters, numbers, and hyphens
            for char in component {
                guard char.isLetter || char.isNumber || char == "-" else { return false }
            }
        }
        
        return true
    }
    
    /// Validate SRV service name format
    /// - Parameter serviceName: The service name to validate
    /// - Returns: true if the service name is valid
    public static func isValidServiceName(_ serviceName: String) -> Bool {
        // Check for basic issues first
        guard !serviceName.isEmpty else { return false }
        guard !serviceName.contains("..") else { return false }
        guard !serviceName.hasPrefix(".") && !serviceName.hasSuffix(".") else { return false }
        
        // SRV records should follow the format: _service._protocol.domain
        let components = serviceName.split(separator: ".")
        guard components.count >= 3 else { return false }
        
        // First component should be service (starting with _)
        let service = String(components[0])
        guard service.hasPrefix("_") && service.count > 1 else { return false }
        
        // Second component should be protocol (starting with _)
        let protocolComponent = String(components[1])
        guard protocolComponent.hasPrefix("_") && protocolComponent.count > 1 else { return false }
        
        // Validate service and protocol names (after underscore)
        let serviceNamePart = String(service.dropFirst())
        let protocolName = String(protocolComponent.dropFirst())
        
        guard isValidServiceComponent(serviceNamePart) else { return false }
        guard isValidServiceComponent(protocolName) else { return false }
        
        // Remaining components should form a valid domain name
        let domain = components.dropFirst(2).joined(separator: ".")
        guard !domain.isEmpty else { return false }
        return isValidHostname(domain)
    }
    
    /// Validate individual service component (service or protocol name)
    /// - Parameter component: The component to validate
    /// - Returns: true if the component is valid
    private static func isValidServiceComponent(_ component: String) -> Bool {
        guard !component.isEmpty else { return false }
        guard component.count <= 15 else { return false } // RFC 6335 recommendation
        
        // Can contain letters, numbers, and hyphens
        for char in component {
            guard char.isLetter || char.isNumber || char == "-" else { return false }
        }
        
        // Must start and end with alphanumeric
        guard component.first?.isLetter == true || component.first?.isNumber == true else { return false }
        guard component.last?.isLetter == true || component.last?.isNumber == true else { return false }
        
        return true
    }
    
    /// Extract service name from SRV record name
    public var serviceName: String? {
        let components = name.split(separator: ".")
        guard components.count >= 1 else { return nil }
        
        let service = String(components[0])
        guard service.hasPrefix("_") && service.count > 1 else { return nil }
        
        return String(service.dropFirst())
    }
    
    /// Extract protocol name from SRV record name
    public var protocolName: String? {
        let components = name.split(separator: ".")
        guard components.count >= 2 else { return nil }
        
        let protocolComponent = String(components[1])
        guard protocolComponent.hasPrefix("_") && protocolComponent.count > 1 else { return nil }
        
        return String(protocolComponent.dropFirst())
    }
    
    /// Extract domain name from SRV record name
    public var domainName: String? {
        let components = name.split(separator: ".")
        guard components.count >= 3 else { return nil }
        
        return components.dropFirst(2).joined(separator: ".")
    }
}

/// Structured data for SRV records containing priority, weight, port, and target information
public struct SRVData: Sendable, Codable, Hashable {
    /// Priority of the service (lower values have higher priority)
    public let priority: Int
    
    /// Weight for load balancing among services with same priority
    public let weight: Int
    
    /// Port number where the service is available
    public let port: Int
    
    /// Target hostname for the service
    public let target: String
    
    /// Initialize SRV data
    /// - Parameters:
    ///   - priority: Service priority (0-65535)
    ///   - weight: Service weight (0-65535)
    ///   - port: Port number (1-65535)
    ///   - target: Target hostname
    public init(priority: Int, weight: Int, port: Int, target: String) {
        self.priority = priority
        self.weight = weight
        self.port = port
        self.target = target
    }
    
    /// Validate that the priority is within valid range
    public var isValidPriority: Bool {
        return priority >= 0 && priority <= 65535
    }
    
    /// Validate that the weight is within valid range
    public var isValidWeight: Bool {
        return weight >= 0 && weight <= 65535
    }
    
    /// Validate that the port is within valid range
    public var isValidPort: Bool {
        return port >= 1 && port <= 65535
    }
    
    /// Validate that the target is a valid hostname
    public var isValidTarget: Bool {
        return SRVRecord.isValidHostname(target)
    }
    
    /// Validate all SRV data fields
    public var isValid: Bool {
        return isValidPriority && isValidWeight && isValidPort && isValidTarget
    }
}

// MARK: - Codable Implementation

extension SRVRecord {
    private enum CodingKeys: String, CodingKey {
        case id
        case zoneId = "zone_id"
        case zoneName = "zone_name"
        case name
        case type
        case content
        case priority
        case weight
        case port
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

extension SRVData {
    private enum CodingKeys: String, CodingKey {
        case priority
        case weight
        case port
        case target
    }
}
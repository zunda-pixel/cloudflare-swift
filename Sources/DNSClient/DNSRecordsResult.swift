import Foundation

/// Result structure for DNS records listing operations
public struct DNSRecordsResult: Sendable, Codable, Hashable {
    /// Array of DNS records returned from the API
    public let records: [AnyDNSRecord]
    
    /// Pagination and result information
    public let resultInfo: ResultInfo?
    
    /// Initialize a new DNS records result
    /// - Parameters:
    ///   - records: Array of DNS records
    ///   - resultInfo: Pagination information
    public init(records: [AnyDNSRecord], resultInfo: ResultInfo? = nil) {
        self.records = records
        self.resultInfo = resultInfo
    }
}

/// Pagination and result information for API responses
public struct ResultInfo: Sendable, Codable, Hashable {
    /// Current page number (1-based)
    public let page: Int
    
    /// Number of records per page
    public let perPage: Int
    
    /// Number of records in current page
    public let count: Int
    
    /// Total number of records across all pages
    public let totalCount: Int
    
    /// Total number of pages available
    public let totalPages: Int
    
    /// Initialize result info
    /// - Parameters:
    ///   - page: Current page number
    ///   - perPage: Records per page
    ///   - count: Records in current page
    ///   - totalCount: Total records available
    ///   - totalPages: Total pages available
    public init(page: Int, perPage: Int, count: Int, totalCount: Int, totalPages: Int) {
        self.page = page
        self.perPage = perPage
        self.count = count
        self.totalCount = totalCount
        self.totalPages = totalPages
    }
    
    private enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case count
        case totalCount = "total_count"
        case totalPages = "total_pages"
    }
}

/// Type-erased wrapper for DNS records to handle mixed record types in collections
public struct AnyDNSRecord: Sendable, Codable, Hashable {
    /// The underlying DNS record
    private let _record: any DNSRecordProtocol
    
    /// Access the underlying record
    public var record: any DNSRecordProtocol { _record }
    
    /// Initialize with a concrete DNS record
    /// - Parameter record: The DNS record to wrap
    public init<T: DNSRecordProtocol>(_ record: T) {
        self._record = record
    }
    
    /// Cast to a specific DNS record type
    /// - Parameter type: The target record type
    /// - Returns: The record cast to the specified type, or nil if casting fails
    public func `as`<T: DNSRecordProtocol>(_ type: T.Type) -> T? {
        return _record as? T
    }
    
    /// Get the record type
    public var type: DNSRecordType {
        return _record.type
    }
    
    /// Get the record name
    public var name: String {
        return _record.name
    }
    
    /// Get the record ID
    public var id: String? {
        return _record.id
    }
    
    // MARK: - Codable Implementation
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(DNSRecordType.self, forKey: .type)
        
        // Decode based on record type
        switch type {
        case .a:
            self._record = try ARecord(from: decoder)
        case .aaaa:
            self._record = try AAAARecord(from: decoder)
        case .cname:
            self._record = try CNAMERecord(from: decoder)
        default:
            // For now, we'll throw an error for unsupported types
            // This will be expanded as we implement more record types
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported DNS record type: \(type.rawValue)"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        // The underlying record handles its own encoding
        try _record.encode(to: encoder)
    }
    
    // MARK: - Hashable Implementation
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_record.id)
        hasher.combine(_record.type)
        hasher.combine(_record.name)
    }
    
    public static func == (lhs: AnyDNSRecord, rhs: AnyDNSRecord) -> Bool {
        return lhs._record.id == rhs._record.id &&
               lhs._record.type == rhs._record.type &&
               lhs._record.name == rhs._record.name
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}
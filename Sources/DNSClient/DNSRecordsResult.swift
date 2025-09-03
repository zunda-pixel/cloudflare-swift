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
    
    /// Get the zone ID
    public var zoneId: String? {
        return _record.zoneId
    }
    
    /// Get the zone name
    public var zoneName: String? {
        return _record.zoneName
    }
    
    /// Get the TTL
    public var ttl: TTL {
        return _record.ttl
    }
    
    /// Get whether the record is proxiable
    public var proxiable: Bool? {
        return _record.proxiable
    }
    
    /// Get whether the record is proxied
    public var proxied: Bool? {
        return _record.proxied
    }
    
    /// Get whether the record is locked
    public var locked: Bool? {
        return _record.locked
    }
    
    /// Get the record comment
    public var comment: String? {
        return _record.comment
    }
    
    /// Get the record tags
    public var tags: [String]? {
        return _record.tags
    }
    
    /// Get when the record was created
    public var createdOn: Date? {
        return _record.createdOn
    }
    
    /// Get when the record was last modified
    public var modifiedOn: Date? {
        return _record.modifiedOn
    }
    
    // MARK: - Type-specific casting helpers
    
    /// Cast to ARecord if this is an A record
    public var asARecord: ARecord? {
        return `as`(ARecord.self)
    }
    
    /// Cast to AAAARecord if this is an AAAA record
    public var asAAAARecord: AAAARecord? {
        return `as`(AAAARecord.self)
    }
    
    /// Cast to CNAMERecord if this is a CNAME record
    public var asCNAMERecord: CNAMERecord? {
        return `as`(CNAMERecord.self)
    }
    
    /// Cast to MXRecord if this is an MX record
    public var asMXRecord: MXRecord? {
        return `as`(MXRecord.self)
    }
    
    /// Cast to TXTRecord if this is a TXT record
    public var asTXTRecord: TXTRecord? {
        return `as`(TXTRecord.self)
    }
    
    /// Cast to SRVRecord if this is an SRV record
    public var asSRVRecord: SRVRecord? {
        return `as`(SRVRecord.self)
    }
    
    /// Cast to CAARecord if this is a CAA record
    public var asCAARecord: CAARecord? {
        return `as`(CAARecord.self)
    }
    
    /// Cast to NSRecord if this is an NS record
    public var asNSRecord: NSRecord? {
        return `as`(NSRecord.self)
    }
    
    /// Cast to PTRRecord if this is a PTR record
    public var asPTRRecord: PTRRecord? {
        return `as`(PTRRecord.self)
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
        case .mx:
            self._record = try MXRecord(from: decoder)
        case .txt:
            self._record = try TXTRecord(from: decoder)
        case .srv:
            self._record = try SRVRecord(from: decoder)
        case .caa:
            self._record = try CAARecord(from: decoder)
        case .ns:
            self._record = try NSRecord(from: decoder)
        case .ptr:
            self._record = try PTRRecord(from: decoder)
        default:
            // For unsupported record types, we'll throw a descriptive error
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported DNS record type: \(type.rawValue). Supported types are: A, AAAA, CNAME, MX, TXT, SRV, CAA, NS, PTR"
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
import Foundation

// MARK: - Batch Operation Models

/// Batch operation request for DNS records
public struct BatchDNSOperation<T: DNSRecordProtocol>: Sendable, Codable {
    /// Array of DNS records to process in the batch
    public let records: [T]
    
    /// Maximum allowed batch size
    public static var maxBatchSize: Int { 100 }
    
    /// Initialize a new batch operation
    /// - Parameter records: Array of DNS records to process
    /// - Throws: DNSRequestError.batchSizeExceeded if records exceed maximum batch size
    public init(records: [T]) throws {
        guard records.count <= Self.maxBatchSize else {
            throw DNSRequestError.batchSizeExceeded(
                count: records.count,
                maximum: Self.maxBatchSize
            )
        }
        
        guard !records.isEmpty else {
            throw DNSRequestError.emptyBatch
        }
        
        self.records = records
    }
    
    /// Validate all records in the batch
    /// - Throws: DNSRequestError for validation failures
    public func validate() throws {
        for (index, record) in records.enumerated() {
            // Validate TTL for each record
            guard record.ttl.isValid else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1004,
                        message: "Invalid TTL value for record at index \(index)"
                    )
                )
            }
            
            // Validate record name is not empty
            guard !record.name.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1005,
                        message: "Record name cannot be empty at index \(index)"
                    )
                )
            }
        }
    }
}

/// Batch operation result containing successful operations and errors
public struct BatchDNSResult<T: DNSRecordProtocol>: Sendable, Codable, Hashable {
    /// Successfully processed records
    public let success: [T]
    
    /// Errors that occurred during batch processing
    public let errors: [BatchError]
    
    /// Total number of operations attempted
    public var totalOperations: Int {
        success.count + errors.count
    }
    
    /// Whether the entire batch was successful
    public var isCompleteSuccess: Bool {
        errors.isEmpty
    }
    
    /// Whether the batch had partial success
    public var isPartialSuccess: Bool {
        !success.isEmpty && !errors.isEmpty
    }
    
    /// Whether the entire batch failed
    public var isCompleteFailure: Bool {
        success.isEmpty && !errors.isEmpty
    }
    
    /// Initialize a batch result
    /// - Parameters:
    ///   - success: Array of successfully processed records
    ///   - errors: Array of errors that occurred
    public init(success: [T], errors: [BatchError]) {
        self.success = success
        self.errors = errors
    }
}

/// Mixed-type batch operation for handling different DNS record types
public struct MixedBatchDNSOperation: Sendable, Codable {
    /// Array of type-erased DNS records to process
    public let records: [AnyDNSRecord]
    
    /// Maximum allowed batch size
    public static var maxBatchSize: Int { 100 }
    
    /// Initialize a new mixed-type batch operation
    /// - Parameter records: Array of type-erased DNS records to process
    /// - Throws: DNSRequestError for validation failures
    public init(records: [AnyDNSRecord]) throws {
        guard records.count <= Self.maxBatchSize else {
            throw DNSRequestError.batchSizeExceeded(
                count: records.count,
                maximum: Self.maxBatchSize
            )
        }
        
        guard !records.isEmpty else {
            throw DNSRequestError.emptyBatch
        }
        
        self.records = records
    }
    
    /// Validate all records in the batch
    /// - Throws: DNSRequestError for validation failures
    public func validate() throws {
        for (index, anyRecord) in records.enumerated() {
            let record = anyRecord.record
            
            // Validate TTL for each record
            guard record.ttl.isValid else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1004,
                        message: "Invalid TTL value for record at index \(index)"
                    )
                )
            }
            
            // Validate record name is not empty
            guard !record.name.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1005,
                        message: "Record name cannot be empty at index \(index)"
                    )
                )
            }
        }
    }
}

/// Mixed-type batch result for different DNS record types
public struct MixedBatchDNSResult: Sendable, Codable, Hashable {
    /// Successfully processed records
    public let success: [AnyDNSRecord]
    
    /// Errors that occurred during batch processing
    public let errors: [BatchError]
    
    /// Total number of operations attempted
    public var totalOperations: Int {
        success.count + errors.count
    }
    
    /// Whether the entire batch was successful
    public var isCompleteSuccess: Bool {
        errors.isEmpty
    }
    
    /// Whether the batch had partial success
    public var isPartialSuccess: Bool {
        !success.isEmpty && !errors.isEmpty
    }
    
    /// Whether the entire batch failed
    public var isCompleteFailure: Bool {
        success.isEmpty && !errors.isEmpty
    }
    
    /// Initialize a mixed batch result
    /// - Parameters:
    ///   - success: Array of successfully processed records
    ///   - errors: Array of errors that occurred
    public init(success: [AnyDNSRecord], errors: [BatchError]) {
        self.success = success
        self.errors = errors
    }
}

// MARK: - Batch Operation Types

/// Types of batch operations supported
public enum BatchOperationType: String, Sendable, Codable, CaseIterable {
    case create = "create"
    case update = "update"
    case delete = "delete"
}

/// Batch delete operation for DNS records
public struct BatchDeleteOperation: Sendable, Codable {
    /// Array of record IDs to delete
    public let recordIds: [String]
    
    /// Maximum allowed batch size for delete operations
    public static var maxBatchSize: Int { 100 }
    
    /// Initialize a new batch delete operation
    /// - Parameter recordIds: Array of record IDs to delete
    /// - Throws: DNSRequestError for validation failures
    public init(recordIds: [String]) throws {
        guard recordIds.count <= Self.maxBatchSize else {
            throw DNSRequestError.batchSizeExceeded(
                count: recordIds.count,
                maximum: Self.maxBatchSize
            )
        }
        
        guard !recordIds.isEmpty else {
            throw DNSRequestError.emptyBatch
        }
        
        // Validate that all IDs are non-empty
        for (index, id) in recordIds.enumerated() {
            guard !id.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1006,
                        message: "Record ID cannot be empty at index \(index)"
                    )
                )
            }
        }
        
        self.recordIds = recordIds
    }
}

/// Batch delete result
public struct BatchDeleteResult: Sendable, Codable, Hashable {
    /// Successfully deleted record IDs
    public let success: [String]
    
    /// Errors that occurred during batch deletion
    public let errors: [BatchError]
    
    /// Total number of delete operations attempted
    public var totalOperations: Int {
        success.count + errors.count
    }
    
    /// Whether the entire batch was successful
    public var isCompleteSuccess: Bool {
        errors.isEmpty
    }
    
    /// Whether the batch had partial success
    public var isPartialSuccess: Bool {
        !success.isEmpty && !errors.isEmpty
    }
    
    /// Whether the entire batch failed
    public var isCompleteFailure: Bool {
        success.isEmpty && !errors.isEmpty
    }
    
    /// Initialize a batch delete result
    /// - Parameters:
    ///   - success: Array of successfully deleted record IDs
    ///   - errors: Array of errors that occurred
    public init(success: [String], errors: [BatchError]) {
        self.success = success
        self.errors = errors
    }
}

// MARK: - Batch Update Operations

/// Single update item for batch update operations
public struct BatchUpdateItem<T: DNSRecordProtocol>: Sendable, Codable {
    /// The ID of the record to update
    public let recordId: String
    
    /// The updated record data
    public let record: T
    
    /// Initialize a batch update item
    /// - Parameters:
    ///   - recordId: The ID of the record to update
    ///   - record: The updated record data
    public init(recordId: String, record: T) {
        self.recordId = recordId
        self.record = record
    }
}

/// Batch update operation for DNS records
public struct BatchUpdateOperation<T: DNSRecordProtocol>: Sendable, Codable {
    /// Array of update items to process in the batch
    public let updates: [BatchUpdateItem<T>]
    
    /// Maximum allowed batch size
    public static var maxBatchSize: Int { 100 }
    
    /// Initialize a new batch update operation
    /// - Parameter updates: Array of update items to process
    /// - Throws: DNSRequestError for validation failures
    public init(updates: [BatchUpdateItem<T>]) throws {
        guard updates.count <= Self.maxBatchSize else {
            throw DNSRequestError.batchSizeExceeded(
                count: updates.count,
                maximum: Self.maxBatchSize
            )
        }
        
        guard !updates.isEmpty else {
            throw DNSRequestError.emptyBatch
        }
        
        self.updates = updates
    }
    
    /// Validate all update items in the batch
    /// - Throws: DNSRequestError for validation failures
    public func validate() throws {
        for (index, updateItem) in updates.enumerated() {
            // Validate record ID is not empty
            guard !updateItem.recordId.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1006,
                        message: "Record ID cannot be empty at index \(index)"
                    )
                )
            }
            
            // Validate TTL for each record
            guard updateItem.record.ttl.isValid else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1004,
                        message: "Invalid TTL value for record at index \(index)"
                    )
                )
            }
            
            // Validate record name is not empty
            guard !updateItem.record.name.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1005,
                        message: "Record name cannot be empty at index \(index)"
                    )
                )
            }
        }
    }
}

/// Mixed-type batch update item for handling different DNS record types
public struct MixedBatchUpdateItem: Sendable, Codable {
    /// The ID of the record to update
    public let recordId: String
    
    /// The updated record data (type-erased)
    public let record: AnyDNSRecord
    
    /// Initialize a mixed batch update item
    /// - Parameters:
    ///   - recordId: The ID of the record to update
    ///   - record: The updated record data
    public init(recordId: String, record: AnyDNSRecord) {
        self.recordId = recordId
        self.record = record
    }
}

/// Mixed-type batch update operation for different DNS record types
public struct MixedBatchUpdateOperation: Sendable, Codable {
    /// Array of mixed-type update items to process
    public let updates: [MixedBatchUpdateItem]
    
    /// Maximum allowed batch size
    public static var maxBatchSize: Int { 100 }
    
    /// Initialize a new mixed-type batch update operation
    /// - Parameter updates: Array of mixed-type update items to process
    /// - Throws: DNSRequestError for validation failures
    public init(updates: [MixedBatchUpdateItem]) throws {
        guard updates.count <= Self.maxBatchSize else {
            throw DNSRequestError.batchSizeExceeded(
                count: updates.count,
                maximum: Self.maxBatchSize
            )
        }
        
        guard !updates.isEmpty else {
            throw DNSRequestError.emptyBatch
        }
        
        self.updates = updates
    }
    
    /// Validate all update items in the batch
    /// - Throws: DNSRequestError for validation failures
    public func validate() throws {
        for (index, updateItem) in updates.enumerated() {
            let record = updateItem.record.record
            
            // Validate record ID is not empty
            guard !updateItem.recordId.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1006,
                        message: "Record ID cannot be empty at index \(index)"
                    )
                )
            }
            
            // Validate TTL for each record
            guard record.ttl.isValid else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1004,
                        message: "Invalid TTL value for record at index \(index)"
                    )
                )
            }
            
            // Validate record name is not empty
            guard !record.name.isEmpty else {
                throw DNSRequestError.batchValidationFailed(
                    index: index,
                    error: DNSMessageContent(
                        code: 1005,
                        message: "Record name cannot be empty at index \(index)"
                    )
                )
            }
        }
    }
}
import Foundation

/// DNS-specific request errors that can occur during API operations
public enum DNSRequestError: Error, Equatable {
    /// The specified zone ID is invalid or not found
    case invalidZoneId
    
    /// The requested DNS record was not found
    case recordNotFound
    
    /// The specified DNS record type is invalid or not supported
    case invalidRecordType
    
    /// The TTL value is outside the valid range (60-86400 seconds, or 1 for automatic)
    case invalidTTL
    
    /// The provided IP address format is invalid (IPv4 or IPv6)
    case invalidIPAddress
    
    /// The provided domain name format is invalid
    case invalidDomainName
    
    /// A record with the same name and type already exists
    case recordAlreadyExists
    
    /// Proxy settings are not supported for this record type
    case proxyNotSupported
    
    /// One or more operations in a batch request failed
    case batchOperationFailed(errors: [BatchError])
    
    /// Batch size exceeds the maximum allowed limit
    case batchSizeExceeded(count: Int, maximum: Int)
    
    /// Batch operation contains no records
    case emptyBatch
    
    /// Validation failed for a record in a batch operation
    case batchValidationFailed(index: Int, error: DNSMessageContent)
    
    /// Authentication failed - invalid API token or insufficient permissions
    case invalidAuthentication
    
    /// The request could not be routed to the appropriate service
    case couldNotRoute(message: String)
    
    /// The API request failed to complete
    case failedFetch(message: String)
    
    /// An unknown error occurred with detailed error information
    case unknown(errors: [DNSMessageContent])
    
    /// Invalid pagination parameters
    case invalidPagination(message: String)
    
    /// Invalid URL construction
    case invalidURL
    
    /// HTTP error with status code
    case httpError(statusCode: Int)
    
    /// Network or connection error
    case networkError(Error)
    
    // MARK: - Equatable Implementation
    
    public static func == (lhs: DNSRequestError, rhs: DNSRequestError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidZoneId, .invalidZoneId),
             (.recordNotFound, .recordNotFound),
             (.invalidRecordType, .invalidRecordType),
             (.invalidTTL, .invalidTTL),
             (.invalidIPAddress, .invalidIPAddress),
             (.invalidDomainName, .invalidDomainName),
             (.recordAlreadyExists, .recordAlreadyExists),
             (.proxyNotSupported, .proxyNotSupported),
             (.invalidAuthentication, .invalidAuthentication),
             (.invalidURL, .invalidURL):
            return true
        case (.couldNotRoute(let lhsMessage), .couldNotRoute(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.failedFetch(let lhsMessage), .failedFetch(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.invalidPagination(let lhsMessage), .invalidPagination(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        case (.batchOperationFailed(let lhsErrors), .batchOperationFailed(let rhsErrors)):
            return lhsErrors == rhsErrors
        case (.batchSizeExceeded(let lhsCount, let lhsMax), .batchSizeExceeded(let rhsCount, let rhsMax)):
            return lhsCount == rhsCount && lhsMax == rhsMax
        case (.emptyBatch, .emptyBatch):
            return true
        case (.batchValidationFailed(let lhsIndex, let lhsError), .batchValidationFailed(let rhsIndex, let rhsError)):
            return lhsIndex == rhsIndex && lhsError == rhsError
        case (.unknown(let lhsErrors), .unknown(let rhsErrors)):
            return lhsErrors == rhsErrors
        case (.networkError(_), .networkError(_)):
            // Network errors are difficult to compare, so we'll consider them equal if both are network errors
            return true
        default:
            return false
        }
    }
}

/// Error information for individual operations in batch requests
public struct BatchError: Sendable, Codable, Hashable {
    /// Index of the failed operation in the batch
    public let index: Int
    
    /// Error details for the failed operation
    public let error: DNSMessageContent
}
import Foundation

/// DNS error handling utilities
public struct DNSErrorHandler {
    /// Maps Cloudflare DNS API error codes to DNSRequestError cases
    /// - Parameter errors: Array of error messages from the API response
    /// - Returns: Appropriate DNSRequestError case based on error codes
    public static func handleError(errors: [DNSMessageContent]) -> DNSRequestError {
        let errorCodes = errors.map(\.code)
        
        // Zone-related errors
        if errorCodes.contains(1003) {
            return .invalidZoneId
        }
        
        // Record-related errors
        else if errorCodes.contains(81044) {
            return .recordNotFound
        }
        else if errorCodes.contains(81053) {
            return .recordAlreadyExists
        }
        
        // Validation errors
        else if errorCodes.contains(1004) {
            return .invalidRecordType
        }
        else if errorCodes.contains(1006) {
            return .invalidTTL
        }
        else if errorCodes.contains(1007) {
            return .invalidIPAddress
        }
        else if errorCodes.contains(1008) {
            return .invalidDomainName
        }
        
        // Proxy-related errors
        else if errorCodes.contains(81057) {
            return .proxyNotSupported
        }
        
        // Authentication errors
        else if errorCodes.contains(10000) {
            return .invalidAuthentication
        }
        
        // Network and routing errors
        else if let error = errors.first(where: { $0.code == 7003 }) {
            return .couldNotRoute(message: error.message)
        }
        else if let error = errors.first(where: { $0.code == 5454 }) {
            return .failedFetch(message: error.message)
        }
        
        // Default to unknown error with all error details
        else {
            return .unknown(errors: errors)
        }
    }
}
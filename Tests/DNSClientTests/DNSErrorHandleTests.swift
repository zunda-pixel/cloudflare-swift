import DNSClient
import Foundation
import HTTPClient
import HTTPTypes
import HTTPTypesFoundation
import Testing

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct DNSErrorHandleTests {

  @Test func invalidZoneIdError() {
    let errors = [DNSMessageContent(code: 1003, message: "Invalid zone ID")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .invalidZoneId = result {
      // Test passes
    } else {
      Issue.record("Expected invalidZoneId error, got \(result)")
    }
  }

  @Test func recordNotFoundError() {
    let errors = [DNSMessageContent(code: 81044, message: "DNS record not found")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .recordNotFound = result {
      // Test passes
    } else {
      Issue.record("Expected recordNotFound error, got \(result)")
    }
  }

  @Test func recordAlreadyExistsError() {
    let errors = [DNSMessageContent(code: 81053, message: "DNS record already exists")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .recordAlreadyExists = result {
      // Test passes
    } else {
      Issue.record("Expected recordAlreadyExists error, got \(result)")
    }
  }

  @Test func invalidRecordTypeError() {
    let errors = [DNSMessageContent(code: 1004, message: "Invalid record type")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .invalidRecordType = result {
      // Test passes
    } else {
      Issue.record("Expected invalidRecordType error, got \(result)")
    }
  }

  @Test func invalidTTLError() {
    let errors = [DNSMessageContent(code: 1006, message: "Invalid TTL value")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .invalidTTL = result {
      // Test passes
    } else {
      Issue.record("Expected invalidTTL error, got \(result)")
    }
  }

  @Test func invalidIPAddressError() {
    let errors = [DNSMessageContent(code: 1007, message: "Invalid IP address")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .invalidIPAddress = result {
      // Test passes
    } else {
      Issue.record("Expected invalidIPAddress error, got \(result)")
    }
  }

  @Test func invalidDomainNameError() {
    let errors = [DNSMessageContent(code: 1008, message: "Invalid domain name")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .invalidDomainName = result {
      // Test passes
    } else {
      Issue.record("Expected invalidDomainName error, got \(result)")
    }
  }

  @Test func proxyNotSupportedError() {
    let errors = [
      DNSMessageContent(code: 81057, message: "Proxy not supported for this record type")
    ]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .proxyNotSupported = result {
      // Test passes
    } else {
      Issue.record("Expected proxyNotSupported error, got \(result)")
    }
  }

  @Test func invalidAuthenticationError() {
    let errors = [DNSMessageContent(code: 10000, message: "Authentication failed")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .invalidAuthentication = result {
      // Test passes
    } else {
      Issue.record("Expected invalidAuthentication error, got \(result)")
    }
  }

  @Test func couldNotRouteError() {
    let errors = [DNSMessageContent(code: 7003, message: "Could not route to service")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .couldNotRoute(let message) = result {
      #expect(message == "Could not route to service")
    } else {
      Issue.record("Expected couldNotRoute error, got \(result)")
    }
  }

  @Test func failedFetchError() {
    let errors = [DNSMessageContent(code: 5454, message: "Failed to fetch data")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .failedFetch(let message) = result {
      #expect(message == "Failed to fetch data")
    } else {
      Issue.record("Expected failedFetch error, got \(result)")
    }
  }

  @Test func unknownError() {
    let errors = [DNSMessageContent(code: 9999, message: "Unknown error")]
    let result = DNSErrorHandler.handleError(errors: errors)

    if case .unknown(let errorMessages) = result {
      #expect(errorMessages.count == 1)
      #expect(errorMessages.first?.code == 9999)
      #expect(errorMessages.first?.message == "Unknown error")
    } else {
      Issue.record("Expected unknown error, got \(result)")
    }
  }

  @Test func multipleErrors() {
    let errors = [
      DNSMessageContent(code: 1003, message: "Invalid zone ID"),
      DNSMessageContent(code: 1004, message: "Invalid record type")
    ]
    let result = DNSErrorHandler.handleError(errors: errors)

    // Should return the first matching error (invalidZoneId in this case)
    if case .invalidZoneId = result {
      // Test passes
    } else {
      Issue.record("Expected invalidZoneId error for multiple errors, got \(result)")
    }
  }
}

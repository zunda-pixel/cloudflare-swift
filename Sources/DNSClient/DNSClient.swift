import Foundation
import HTTPClient
import HTTPTypes

/// DNS client for managing Cloudflare DNS records
public struct DNSClient<HTTPClient: HTTPClientProtocol & Sendable>: Sendable {
  /// Cloudflare API token for authentication
  public let apiToken: String

  /// HTTP client for making API requests
  public let httpClient: HTTPClient

  /// Base URL for Cloudflare API
  public var baseURL = URL(string: "https://api.cloudflare.com/client/v4")!

  /// Initialize a new DNS client
  /// - Parameters:
  ///   - apiToken: Cloudflare API token with DNS permissions
  ///   - httpClient: HTTP client implementation for making requests
  public init(
    apiToken: String,
    httpClient: HTTPClient
  ) {
    self.apiToken = apiToken
    self.httpClient = httpClient
  }

  /// Execute an HTTP request with authentication
  /// - Parameters:
  ///   - request: HTTP request to execute
  ///   - body: Optional request body data
  /// - Returns: Response data and HTTP response
  func execute(_ request: HTTPRequest, body: Data? = nil) async throws -> (Data, HTTPResponse) {
    var request = request
    request.headerFields[.authorization] = "Bearer \(apiToken)"
    return try await httpClient.execute(for: request, from: body)
  }
}
// MARK: - DNS Record Operations

extension DNSClient {
  /// List DNS records for a zone with optional filtering and pagination
  /// - Parameters:
  ///   - zoneId: The zone identifier to list records for
  ///   - type: Optional DNS record type filter
  ///   - name: Optional name filter (supports partial matching)
  ///   - page: Page number for pagination (default: 1)
  ///   - perPage: Number of records per page (default: 100, max: 5000)
  /// - Returns: DNS records result with pagination information
  /// - Throws: DNSRequestError for various failure scenarios
  public func listDNSRecords(
    zoneId: String,
    type: DNSRecordType? = nil,
    name: String? = nil,
    page: Int = 1,
    perPage: Int = 100
  ) async throws -> DNSRecordsResult {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    guard page > 0 else {
      throw DNSRequestError.invalidPagination(message: "Page must be greater than 0")
    }

    guard perPage > 0 && perPage <= 5000 else {
      throw DNSRequestError.invalidPagination(message: "Per page must be between 1 and 5000")
    }

    // Build URL with query parameters
    var urlComponents = URLComponents(
      url: baseURL.appendingPathComponent("zones/\(zoneId)/dns_records"),
      resolvingAgainstBaseURL: false)!

    var queryItems: [URLQueryItem] = [
      URLQueryItem(name: "page", value: String(page)),
      URLQueryItem(name: "per_page", value: String(perPage))
    ]

    if let type = type {
      queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
    }

    if let name = name, !name.isEmpty {
      queryItems.append(URLQueryItem(name: "name", value: name))
    }

    urlComponents.queryItems = queryItems

    guard let url = urlComponents.url else {
      throw DNSRequestError.invalidURL
    }

    // Create and execute request
    let request = HTTPRequest(method: .get, url: url)

    do {
      let (data, _) = try await execute(request)

      // Parse response first to get DNS-specific errors
      let dnsResponse = try JSONDecoder.dns.decode(DNSResponse<[AnyDNSRecord]>.self, from: data)

      if dnsResponse.success, let records = dnsResponse.result {
        // Parse result_info from the response if present
        let resultInfo: ResultInfo?
        if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let resultInfoData = responseDict["result_info"] as? [String: Any]
        {
          let resultInfoJSON = try JSONSerialization.data(withJSONObject: resultInfoData)
          resultInfo = try? JSONDecoder.dns.decode(ResultInfo.self, from: resultInfoJSON)
        } else {
          resultInfo = nil
        }

        return DNSRecordsResult(
          records: records,
          resultInfo: resultInfo
        )
      } else {
        throw Self.handleError(errors: dnsResponse.errors)
      }

    } catch let error as DNSRequestError {
      throw error
    } catch {
      throw DNSRequestError.networkError(error)
    }
  }

  /// Create a new DNS record
  /// - Parameters:
  ///   - zoneId: The zone identifier to create the record in
  ///   - record: The DNS record to create
  /// - Returns: The created DNS record with server-assigned values
  /// - Throws: DNSRequestError for various failure scenarios
  public func createDNSRecord<T: DNSRecordProtocol>(
    zoneId: String,
    record: T
  ) async throws -> T {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    // Validate TTL
    guard record.ttl.isValid else {
      throw DNSRequestError.invalidTTL
    }

    // Build URL
    let url = baseURL.appendingPathComponent("zones/\(zoneId)/dns_records")

    // Create request body
    let requestBody = try JSONEncoder().encode(record)

    // Create and execute request
    var request = HTTPRequest(method: .post, url: url)
    request.headerFields[.contentType] = "application/json"

    do {
      let (data, _) = try await execute(request, body: requestBody)

      // Parse response first to get DNS-specific errors
      let dnsResponse = try JSONDecoder.dns.decode(DNSResponse<T>.self, from: data)

      if dnsResponse.success, let createdRecord = dnsResponse.result {
        return createdRecord
      } else {
        throw Self.handleError(errors: dnsResponse.errors)
      }

    } catch let error as DNSRequestError {
      throw error
    } catch {
      throw DNSRequestError.networkError(error)
    }
  }

  /// Update an existing DNS record
  /// - Parameters:
  ///   - zoneId: The zone identifier containing the record
  ///   - recordId: The identifier of the record to update
  ///   - record: The updated DNS record data
  /// - Returns: The updated DNS record with server-assigned values
  /// - Throws: DNSRequestError for various failure scenarios
  public func updateDNSRecord<T: DNSRecordProtocol>(
    zoneId: String,
    recordId: String,
    record: T
  ) async throws -> T {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    guard !recordId.isEmpty else {
      throw DNSRequestError.recordNotFound
    }

    // Validate TTL
    guard record.ttl.isValid else {
      throw DNSRequestError.invalidTTL
    }

    // Build URL
    let url = baseURL.appendingPathComponent("zones/\(zoneId)/dns_records/\(recordId)")

    // Create request body
    let requestBody = try JSONEncoder().encode(record)

    // Create and execute request
    var request = HTTPRequest(method: .put, url: url)
    request.headerFields[.contentType] = "application/json"

    do {
      let (data, _) = try await execute(request, body: requestBody)

      // Parse response first to get DNS-specific errors
      let dnsResponse = try JSONDecoder.dns.decode(DNSResponse<T>.self, from: data)

      if dnsResponse.success, let updatedRecord = dnsResponse.result {
        return updatedRecord
      } else {
        throw Self.handleError(errors: dnsResponse.errors)
      }

    } catch let error as DNSRequestError {
      throw error
    } catch {
      throw DNSRequestError.networkError(error)
    }
  }

  /// Delete a DNS record
  /// - Parameters:
  ///   - zoneId: The zone identifier containing the record
  ///   - recordId: The identifier of the record to delete
  /// - Returns: Confirmation of the deletion with the record ID
  /// - Throws: DNSRequestError for various failure scenarios
  public func deleteDNSRecord(
    zoneId: String,
    recordId: String
  ) async throws -> DNSDeleteResult {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    guard !recordId.isEmpty else {
      throw DNSRequestError.recordNotFound
    }

    // Build URL
    let url = baseURL.appendingPathComponent("zones/\(zoneId)/dns_records/\(recordId)")

    // Create and execute request
    let request = HTTPRequest(method: .delete, url: url)

    do {
      let (data, _) = try await execute(request)

      // Parse response
      let dnsResponse = try JSONDecoder.dns.decode(DNSResponse<DNSDeleteResult>.self, from: data)

      if dnsResponse.success, let deleteResult = dnsResponse.result {
        return deleteResult
      } else {
        throw Self.handleError(errors: dnsResponse.errors)
      }

    } catch let error as DNSRequestError {
      throw error
    } catch {
      throw DNSRequestError.networkError(error)
    }
  }
}

// MARK: - Batch Operations

extension DNSClient {
  /// Create multiple DNS records in a single batch operation
  /// - Parameters:
  ///   - zoneId: The zone identifier to create records in
  ///   - operation: Batch operation containing records to create
  /// - Returns: Batch result with successful records and any errors
  /// - Throws: DNSRequestError for various failure scenarios
  public func batchCreateDNSRecords<T: DNSRecordProtocol>(
    zoneId: String,
    operation: BatchDNSOperation<T>
  ) async throws -> BatchDNSResult<T> {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    // Validate the batch operation
    try operation.validate()

    var successfulRecords: [T] = []
    var batchErrors: [BatchError] = []

    // Process records individually since Cloudflare doesn't support true batch create
    // This simulates batch behavior by processing multiple records sequentially
    for (index, record) in operation.records.enumerated() {
      do {
        let createdRecord = try await createDNSRecord(zoneId: zoneId, record: record)
        successfulRecords.append(createdRecord)
      } catch let error as DNSRequestError {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: mapErrorToCode(error),
            message: mapErrorToMessage(error)
          )
        )
        batchErrors.append(batchError)
      } catch {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: 9999,
            message: "Unexpected error: \(error.localizedDescription)"
          )
        )
        batchErrors.append(batchError)
      }
    }

    return BatchDNSResult(success: successfulRecords, errors: batchErrors)
  }

  /// Create multiple DNS records of mixed types in a single batch operation
  /// - Parameters:
  ///   - zoneId: The zone identifier to create records in
  ///   - operation: Mixed batch operation containing different record types
  /// - Returns: Mixed batch result with successful records and any errors
  /// - Throws: DNSRequestError for various failure scenarios
  public func batchCreateMixedDNSRecords(
    zoneId: String,
    operation: MixedBatchDNSOperation
  ) async throws -> MixedBatchDNSResult {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    // Validate the batch operation
    try operation.validate()

    var successfulRecords: [AnyDNSRecord] = []
    var batchErrors: [BatchError] = []

    // Process records individually
    for (index, anyRecord) in operation.records.enumerated() {
      do {
        let createdRecord = try await createMixedDNSRecord(zoneId: zoneId, record: anyRecord)
        successfulRecords.append(createdRecord)
      } catch let error as DNSRequestError {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: mapErrorToCode(error),
            message: mapErrorToMessage(error)
          )
        )
        batchErrors.append(batchError)
      } catch {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: 9999,
            message: "Unexpected error: \(error.localizedDescription)"
          )
        )
        batchErrors.append(batchError)
      }
    }

    return MixedBatchDNSResult(success: successfulRecords, errors: batchErrors)
  }

  /// Update multiple DNS records in a single batch operation
  /// - Parameters:
  ///   - zoneId: The zone identifier containing the records
  ///   - operation: Batch operation containing records to update with their IDs
  /// - Returns: Batch result with successful records and any errors
  /// - Throws: DNSRequestError for various failure scenarios
  public func batchUpdateDNSRecords<T: DNSRecordProtocol>(
    zoneId: String,
    operation: BatchUpdateOperation<T>
  ) async throws -> BatchDNSResult<T> {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    // Validate the batch operation
    try operation.validate()

    var successfulRecords: [T] = []
    var batchErrors: [BatchError] = []

    // Process records individually since Cloudflare doesn't support true batch update
    for (index, updateItem) in operation.updates.enumerated() {
      do {
        let updatedRecord = try await updateDNSRecord(
          zoneId: zoneId,
          recordId: updateItem.recordId,
          record: updateItem.record
        )
        successfulRecords.append(updatedRecord)
      } catch let error as DNSRequestError {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: mapErrorToCode(error),
            message: mapErrorToMessage(error)
          )
        )
        batchErrors.append(batchError)
      } catch {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: 9999,
            message: "Unexpected error: \(error.localizedDescription)"
          )
        )
        batchErrors.append(batchError)
      }
    }

    return BatchDNSResult(success: successfulRecords, errors: batchErrors)
  }

  /// Update multiple DNS records of mixed types in a single batch operation
  /// - Parameters:
  ///   - zoneId: The zone identifier containing the records
  ///   - operation: Mixed batch update operation containing different record types
  /// - Returns: Mixed batch result with successful records and any errors
  /// - Throws: DNSRequestError for various failure scenarios
  public func batchUpdateMixedDNSRecords(
    zoneId: String,
    operation: MixedBatchUpdateOperation
  ) async throws -> MixedBatchDNSResult {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    // Validate the batch operation
    try operation.validate()

    var successfulRecords: [AnyDNSRecord] = []
    var batchErrors: [BatchError] = []

    // Process records individually
    for (index, updateItem) in operation.updates.enumerated() {
      do {
        let updatedRecord = try await updateMixedDNSRecord(
          zoneId: zoneId,
          recordId: updateItem.recordId,
          record: updateItem.record
        )
        successfulRecords.append(updatedRecord)
      } catch let error as DNSRequestError {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: mapErrorToCode(error),
            message: mapErrorToMessage(error)
          )
        )
        batchErrors.append(batchError)
      } catch {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: 9999,
            message: "Unexpected error: \(error.localizedDescription)"
          )
        )
        batchErrors.append(batchError)
      }
    }

    return MixedBatchDNSResult(success: successfulRecords, errors: batchErrors)
  }

  /// Delete multiple DNS records in a single batch operation
  /// - Parameters:
  ///   - zoneId: The zone identifier containing the records
  ///   - operation: Batch delete operation containing record IDs to delete
  /// - Returns: Batch delete result with successful deletions and any errors
  /// - Throws: DNSRequestError for various failure scenarios
  public func batchDeleteDNSRecords(
    zoneId: String,
    operation: BatchDeleteOperation
  ) async throws -> BatchDeleteResult {
    // Validate parameters
    guard !zoneId.isEmpty else {
      throw DNSRequestError.invalidZoneId
    }

    var successfulDeletions: [String] = []
    var batchErrors: [BatchError] = []

    // Process deletions individually since Cloudflare doesn't support true batch delete
    for (index, recordId) in operation.recordIds.enumerated() {
      do {
        let deleteResult = try await deleteDNSRecord(zoneId: zoneId, recordId: recordId)
        successfulDeletions.append(deleteResult.id)
      } catch let error as DNSRequestError {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: mapErrorToCode(error),
            message: mapErrorToMessage(error)
          )
        )
        batchErrors.append(batchError)
      } catch {
        let batchError = BatchError(
          index: index,
          error: DNSMessageContent(
            code: 9999,
            message: "Unexpected error: \(error.localizedDescription)"
          )
        )
        batchErrors.append(batchError)
      }
    }

    return BatchDeleteResult(success: successfulDeletions, errors: batchErrors)
  }

  /// Create a single DNS record from a type-erased record
  /// - Parameters:
  ///   - zoneId: The zone identifier to create the record in
  ///   - record: Type-erased DNS record to create
  /// - Returns: The created record wrapped in AnyDNSRecord
  /// - Throws: DNSRequestError for various failure scenarios
  private func createMixedDNSRecord(
    zoneId: String,
    record: AnyDNSRecord
  ) async throws -> AnyDNSRecord {
    let underlyingRecord = record.record

    // Use type casting to call the appropriate create method
    if let aRecord = underlyingRecord as? ARecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: aRecord)
      return AnyDNSRecord(created)
    } else if let aaaaRecord = underlyingRecord as? AAAARecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: aaaaRecord)
      return AnyDNSRecord(created)
    } else if let cnameRecord = underlyingRecord as? CNAMERecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: cnameRecord)
      return AnyDNSRecord(created)
    } else if let mxRecord = underlyingRecord as? MXRecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: mxRecord)
      return AnyDNSRecord(created)
    } else if let txtRecord = underlyingRecord as? TXTRecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: txtRecord)
      return AnyDNSRecord(created)
    } else if let srvRecord = underlyingRecord as? SRVRecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: srvRecord)
      return AnyDNSRecord(created)
    } else if let caaRecord = underlyingRecord as? CAARecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: caaRecord)
      return AnyDNSRecord(created)
    } else if let nsRecord = underlyingRecord as? NSRecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: nsRecord)
      return AnyDNSRecord(created)
    } else if let ptrRecord = underlyingRecord as? PTRRecord {
      let created = try await createDNSRecord(zoneId: zoneId, record: ptrRecord)
      return AnyDNSRecord(created)
    } else {
      throw DNSRequestError.invalidRecordType
    }
  }

  /// Update a single DNS record from a type-erased record
  /// - Parameters:
  ///   - zoneId: The zone identifier containing the record
  ///   - recordId: The identifier of the record to update
  ///   - record: Type-erased DNS record to update
  /// - Returns: The updated record wrapped in AnyDNSRecord
  /// - Throws: DNSRequestError for various failure scenarios
  private func updateMixedDNSRecord(
    zoneId: String,
    recordId: String,
    record: AnyDNSRecord
  ) async throws -> AnyDNSRecord {
    let underlyingRecord = record.record

    // Use type casting to call the appropriate update method
    if let aRecord = underlyingRecord as? ARecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: aRecord)
      return AnyDNSRecord(updated)
    } else if let aaaaRecord = underlyingRecord as? AAAARecord {
      let updated = try await updateDNSRecord(
        zoneId: zoneId, recordId: recordId, record: aaaaRecord)
      return AnyDNSRecord(updated)
    } else if let cnameRecord = underlyingRecord as? CNAMERecord {
      let updated = try await updateDNSRecord(
        zoneId: zoneId, recordId: recordId, record: cnameRecord)
      return AnyDNSRecord(updated)
    } else if let mxRecord = underlyingRecord as? MXRecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: mxRecord)
      return AnyDNSRecord(updated)
    } else if let txtRecord = underlyingRecord as? TXTRecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: txtRecord)
      return AnyDNSRecord(updated)
    } else if let srvRecord = underlyingRecord as? SRVRecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: srvRecord)
      return AnyDNSRecord(updated)
    } else if let caaRecord = underlyingRecord as? CAARecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: caaRecord)
      return AnyDNSRecord(updated)
    } else if let nsRecord = underlyingRecord as? NSRecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: nsRecord)
      return AnyDNSRecord(updated)
    } else if let ptrRecord = underlyingRecord as? PTRRecord {
      let updated = try await updateDNSRecord(zoneId: zoneId, recordId: recordId, record: ptrRecord)
      return AnyDNSRecord(updated)
    } else {
      throw DNSRequestError.invalidRecordType
    }
  }

  /// Map DNSRequestError to error code for batch operations
  /// - Parameter error: The DNS request error
  /// - Returns: Appropriate error code
  private func mapErrorToCode(_ error: DNSRequestError) -> Int {
    switch error {
    case .invalidZoneId:
      return 1003
    case .recordNotFound:
      return 81044
    case .invalidRecordType:
      return 1004
    case .invalidTTL:
      return 1004
    case .invalidIPAddress:
      return 1004
    case .invalidDomainName:
      return 1004
    case .recordAlreadyExists:
      return 81057
    case .proxyNotSupported:
      return 1004
    case .invalidAuthentication:
      return 10000
    case .batchSizeExceeded:
      return 1004
    case .emptyBatch:
      return 1004
    case .batchValidationFailed:
      return 1004
    default:
      return 9999
    }
  }

  /// Map DNSRequestError to error message for batch operations
  /// - Parameter error: The DNS request error
  /// - Returns: Human-readable error message
  private func mapErrorToMessage(_ error: DNSRequestError) -> String {
    switch error {
    case .invalidZoneId:
      return "Invalid zone ID"
    case .recordNotFound:
      return "DNS record not found"
    case .invalidRecordType:
      return "Invalid DNS record type"
    case .invalidTTL:
      return "Invalid TTL value"
    case .invalidIPAddress:
      return "Invalid IP address format"
    case .invalidDomainName:
      return "Invalid domain name format"
    case .recordAlreadyExists:
      return "DNS record already exists"
    case .proxyNotSupported:
      return "Proxy not supported for this record type"
    case .invalidAuthentication:
      return "Invalid authentication credentials"
    case .batchSizeExceeded(let count, let maximum):
      return "Batch size \(count) exceeds maximum \(maximum)"
    case .emptyBatch:
      return "Batch operation cannot be empty"
    case .batchValidationFailed(let index, let error):
      return "Validation failed at index \(index): \(error.message)"
    case .couldNotRoute(let message):
      return "Could not route request: \(message)"
    case .failedFetch(let message):
      return "Failed to fetch: \(message)"
    case .invalidPagination(let message):
      return "Invalid pagination: \(message)"
    case .invalidURL:
      return "Invalid URL"
    case .httpError(let statusCode):
      return "HTTP error with status code \(statusCode)"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    case .batchOperationFailed(let errors):
      return "Batch operation failed with \(errors.count) errors"
    case .unknown(let errors):
      return "Unknown error: \(errors.map(\.message).joined(separator: ", "))"
    }
  }
}

// MARK: - Error Handling

extension DNSClient {
  /// Maps Cloudflare DNS API error codes to DNSRequestError cases
  /// - Parameter errors: Array of error messages from the API response
  /// - Returns: Appropriate DNSRequestError case based on error codes
  static func handleError(errors: [DNSMessageContent]) -> DNSRequestError {
    return DNSErrorHandler.handleError(errors: errors)
  }
}

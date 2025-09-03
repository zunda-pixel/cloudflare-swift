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
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("zones/\(zoneId)/dns_records"), resolvingAgainstBaseURL: false)!
        
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
                   let resultInfoData = responseDict["result_info"] as? [String: Any] {
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

// MARK: - Error Handling

extension DNSClient {
    /// Maps Cloudflare DNS API error codes to DNSRequestError cases
    /// - Parameter errors: Array of error messages from the API response
    /// - Returns: Appropriate DNSRequestError case based on error codes
    static func handleError(errors: [DNSMessageContent]) -> DNSRequestError {
        return DNSErrorHandler.handleError(errors: errors)
    }
}


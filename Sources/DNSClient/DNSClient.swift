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
            let (data, response) = try await execute(request)
            
            // Check HTTP status
            guard response.status.kind == .successful else {
                throw DNSRequestError.httpError(statusCode: response.status.code)
            }
            
            // Parse response
            let dnsResponse = try JSONDecoder.dns.decode(DNSResponse<[AnyDNSRecord]>.self, from: data)
            
            if dnsResponse.success, let records = dnsResponse.result {
                // Parse result_info from the response if present
                let resultInfo: ResultInfo?
                if let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let resultInfoData = data["result_info"] as? [String: Any] {
                    resultInfo = try? JSONDecoder.dns.decode(ResultInfo.self, from: JSONSerialization.data(withJSONObject: resultInfoData))
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

// MARK: - Internal Response Models

/// Internal response model for DNS records listing
private struct DNSListResponse: Sendable, Codable, Hashable {
    let records: [AnyDNSRecord]
    let resultInfo: ResultInfo?
    
    private enum CodingKeys: String, CodingKey {
        case records = "result"
        case resultInfo = "result_info"
    }
}
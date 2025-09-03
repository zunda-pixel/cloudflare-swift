import Testing
import Foundation
@testable import DNSClient
import HTTPClient
import HTTPTypes

@Suite("DNS Record Listing Tests")
struct DNSRecordListingTests {
    
    // MARK: - Test Helpers
    
    private func createMockClient() -> DNSClient<MockHTTPClient> {
        return DNSClient(apiToken: "test-token", httpClient: MockHTTPClient())
    }
    
    private func createSuccessResponse(records: [[String: Any]], resultInfo: [String: Any]? = nil) -> Data {
        var response: [String: Any] = [
            "success": true,
            "errors": [],
            "messages": [],
            "result": records
        ]
        
        if let resultInfo = resultInfo {
            response["result_info"] = resultInfo
        }
        
        return try! JSONSerialization.data(withJSONObject: response)
    }
    
    private func createErrorResponse(errors: [[String: Any]]) -> Data {
        let response: [String: Any] = [
            "success": false,
            "errors": errors,
            "messages": [],
            "result": NSNull()
        ]
        
        return try! JSONSerialization.data(withJSONObject: response)
    }
    
    // MARK: - Basic Listing Tests
    
    @Test("List DNS records successfully")
    func testListDNSRecords_Success() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            [
                "id": "record2",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "www.example.com",
                "type": "CNAME",
                "content": "example.com",
                "ttl": 1,
                "proxiable": true,
                "proxied": true,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        let resultInfo = [
            "page": 1,
            "per_page": 100,
            "count": 2,
            "total_count": 2,
            "total_pages": 1
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords, resultInfo: resultInfo),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123")
        
        #expect(result.records.count == 2)
        #expect(result.resultInfo != nil)
        #expect(result.resultInfo?.page == 1)
        #expect(result.resultInfo?.totalCount == 2)
        
        // Verify first record
        let firstRecord = result.records[0]
        #expect(firstRecord.type == .a)
        #expect(firstRecord.name == "example.com")
        #expect(firstRecord.id == "record1")
        
        // Verify second record
        let secondRecord = result.records[1]
        #expect(secondRecord.type == .cname)
        #expect(secondRecord.name == "www.example.com")
        #expect(secondRecord.id == "record2")
    }
    
    @Test("List DNS records with type filter")
    func testListDNSRecords_WithTypeFilter() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123", type: .a)
        
        #expect(result.records.count == 1)
        #expect(result.records[0].type == .a)
        
        // Verify the request URL contains the type filter
        let lastRequest = client.httpClient.lastRequest
        #expect(lastRequest != nil)
        #expect(lastRequest!.url!.absoluteString.contains("type=A"))
    }
    
    @Test("List DNS records with name filter")
    func testListDNSRecords_WithNameFilter() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "www.example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123", name: "www.example.com")
        
        #expect(result.records.count == 1)
        #expect(result.records[0].name == "www.example.com")
        
        // Verify the request URL contains the name filter
        let lastRequest = client.httpClient.lastRequest
        #expect(lastRequest != nil)
        #expect(lastRequest!.url!.absoluteString.contains("name=www.example.com"))
    }
    
    @Test("List DNS records with pagination")
    func testListDNSRecords_WithPagination() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        let resultInfo = [
            "page": 2,
            "per_page": 50,
            "count": 1,
            "total_count": 100,
            "total_pages": 2
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords, resultInfo: resultInfo),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123", page: 2, perPage: 50)
        
        #expect(result.records.count == 1)
        #expect(result.resultInfo?.page == 2)
        #expect(result.resultInfo?.perPage == 50)
        #expect(result.resultInfo?.totalCount == 100)
        
        // Verify the request URL contains pagination parameters
        let lastRequest = client.httpClient.lastRequest
        #expect(lastRequest != nil)
        #expect(lastRequest!.url!.absoluteString.contains("page=2"))
        #expect(lastRequest!.url!.absoluteString.contains("per_page=50"))
    }
    
    // MARK: - Error Handling Tests
    
    @Test("List DNS records with invalid zone ID")
    func testListDNSRecords_InvalidZoneId() async throws {
        let client = createMockClient()
        
        do {
            _ = try await client.listDNSRecords(zoneId: "")
            Issue.record("Expected error for empty zone ID")
        } catch DNSRequestError.invalidZoneId {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("List DNS records with invalid pagination")
    func testListDNSRecords_InvalidPagination() async throws {
        let client = createMockClient()
        
        // Test invalid page number
        do {
            _ = try await client.listDNSRecords(zoneId: "zone123", page: 0)
            Issue.record("Expected error for invalid page number")
        } catch DNSRequestError.invalidPagination {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
        // Test invalid per page value
        do {
            _ = try await client.listDNSRecords(zoneId: "zone123", perPage: 0)
            Issue.record("Expected error for invalid per page value")
        } catch DNSRequestError.invalidPagination {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        
        // Test per page value too large
        do {
            _ = try await client.listDNSRecords(zoneId: "zone123", perPage: 6000)
            Issue.record("Expected error for per page value too large")
        } catch DNSRequestError.invalidPagination {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("List DNS records with API error")
    func testListDNSRecords_APIError() async throws {
        let client = createMockClient()
        
        let errors = [
            [
                "code": 1003,
                "message": "Invalid zone identifier"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createErrorResponse(errors: errors),
            HTTPResponse(status: .badRequest)
        )
        
        do {
            _ = try await client.listDNSRecords(zoneId: "invalid-zone")
            Issue.record("Expected error for API failure")
        } catch DNSRequestError.invalidZoneId {
            // Expected error based on error code mapping
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("List DNS records with network error")
    func testListDNSRecords_NetworkError() async throws {
        let client = createMockClient()
        
        // Return invalid JSON to simulate network/parsing error
        client.httpClient.mockResponse = (
            Data("invalid json".utf8),
            HTTPResponse(status: .internalServerError)
        )
        
        do {
            _ = try await client.listDNSRecords(zoneId: "zone123")
            Issue.record("Expected error for network failure")
        } catch DNSRequestError.networkError {
            // Expected error for JSON parsing failure
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("List DNS records with empty result")
    func testListDNSRecords_EmptyResult() async throws {
        let client = createMockClient()
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: []),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123")
        
        #expect(result.records.count == 0)
        #expect(result.resultInfo == nil)
    }
    
    // MARK: - Mixed Record Type Tests
    
    @Test("List DNS records with mixed record types")
    func testListDNSRecords_MixedRecordTypes() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            // A Record
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // AAAA Record
            [
                "id": "record2",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "AAAA",
                "content": "2001:db8::1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // CNAME Record
            [
                "id": "record3",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "www.example.com",
                "type": "CNAME",
                "content": "example.com",
                "ttl": 1,
                "proxiable": true,
                "proxied": true,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // MX Record
            [
                "id": "record4",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "MX",
                "content": "mail.example.com",
                "priority": 10,
                "data": [
                    "priority": 10,
                    "target": "mail.example.com"
                ],
                "ttl": 300,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // TXT Record
            [
                "id": "record5",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "TXT",
                "content": "v=spf1 include:_spf.google.com ~all",
                "ttl": 300,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // SRV Record
            [
                "id": "record6",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "_sip._tcp.example.com",
                "type": "SRV",
                "content": "sip.example.com",
                "priority": 10,
                "weight": 5,
                "port": 5060,
                "data": [
                    "priority": 10,
                    "weight": 5,
                    "port": 5060,
                    "target": "sip.example.com"
                ],
                "ttl": 300,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // CAA Record
            [
                "id": "record7",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "CAA",
                "content": "0 issue letsencrypt.org",
                "flags": 0,
                "tag": "issue",
                "value": "letsencrypt.org",
                "data": [
                    "flags": 0,
                    "tag": "issue",
                    "value": "letsencrypt.org"
                ],
                "ttl": 300,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // NS Record
            [
                "id": "record8",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "subdomain.example.com",
                "type": "NS",
                "content": "ns1.example.com",
                "ttl": 86400,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ],
            // PTR Record
            [
                "id": "record9",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "1.1.168.192.in-addr.arpa",
                "type": "PTR",
                "content": "example.com",
                "ttl": 300,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123")
        
        #expect(result.records.count == 9)
        
        // Test type-specific casting
        let aRecord = result.records[0].asARecord
        #expect(aRecord != nil)
        #expect(aRecord?.content == "192.168.1.1")
        #expect(aRecord?.type == .a)
        
        let aaaaRecord = result.records[1].asAAAARecord
        #expect(aaaaRecord != nil)
        #expect(aaaaRecord?.content == "2001:db8::1")
        #expect(aaaaRecord?.type == .aaaa)
        
        let cnameRecord = result.records[2].asCNAMERecord
        #expect(cnameRecord != nil)
        #expect(cnameRecord?.content == "example.com")
        #expect(cnameRecord?.type == .cname)
        
        let mxRecord = result.records[3].asMXRecord
        #expect(mxRecord != nil)
        #expect(mxRecord?.content == "mail.example.com")
        #expect(mxRecord?.priority == 10)
        #expect(mxRecord?.type == .mx)
        
        let txtRecord = result.records[4].asTXTRecord
        #expect(txtRecord != nil)
        #expect(txtRecord?.content == "v=spf1 include:_spf.google.com ~all")
        #expect(txtRecord?.type == .txt)
        
        let srvRecord = result.records[5].asSRVRecord
        #expect(srvRecord != nil)
        #expect(srvRecord?.content == "sip.example.com")
        #expect(srvRecord?.priority == 10)
        #expect(srvRecord?.weight == 5)
        #expect(srvRecord?.port == 5060)
        #expect(srvRecord?.type == .srv)
        
        let caaRecord = result.records[6].asCAARecord
        #expect(caaRecord != nil)
        #expect(caaRecord?.content == "0 issue letsencrypt.org")
        #expect(caaRecord?.flags == 0)
        #expect(caaRecord?.tag == "issue")
        #expect(caaRecord?.value == "letsencrypt.org")
        #expect(caaRecord?.type == .caa)
        
        let nsRecord = result.records[7].asNSRecord
        #expect(nsRecord != nil)
        #expect(nsRecord?.content == "ns1.example.com")
        #expect(nsRecord?.type == .ns)
        
        let ptrRecord = result.records[8].asPTRRecord
        #expect(ptrRecord != nil)
        #expect(ptrRecord?.content == "example.com")
        #expect(ptrRecord?.type == .ptr)
        
        // Test generic access through AnyDNSRecord
        for (index, record) in result.records.enumerated() {
            #expect(record.id == "record\(index + 1)")
            #expect(record.zoneId == "zone123")
            #expect(record.zoneName == "example.com")
            #expect(record.createdOn != nil)
            #expect(record.modifiedOn != nil)
        }
        
        // Test type filtering through AnyDNSRecord
        let aRecords = result.records.filter { $0.type == .a }
        #expect(aRecords.count == 1)
        
        let mxRecords = result.records.filter { $0.type == .mx }
        #expect(mxRecords.count == 1)
        
        let proxiableRecords = result.records.filter { $0.proxiable == true }
        #expect(proxiableRecords.count == 3) // A, AAAA, CNAME
        
        let proxiedRecords = result.records.filter { $0.proxied == true }
        #expect(proxiedRecords.count == 1) // Only CNAME
    }
    
    @Test("AnyDNSRecord type casting")
    func testAnyDNSRecord_TypeCasting() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(zoneId: "zone123")
        let anyRecord = result.records[0]
        
        // Test successful casting
        let aRecord = anyRecord.as(ARecord.self)
        #expect(aRecord != nil)
        #expect(aRecord?.content == "192.168.1.1")
        
        // Test failed casting
        let mxRecord = anyRecord.as(MXRecord.self)
        #expect(mxRecord == nil)
        
        // Test convenience properties
        #expect(anyRecord.asARecord != nil)
        #expect(anyRecord.asMXRecord == nil)
        #expect(anyRecord.asCNAMERecord == nil)
        #expect(anyRecord.asTXTRecord == nil)
        #expect(anyRecord.asSRVRecord == nil)
        #expect(anyRecord.asCAARecord == nil)
        #expect(anyRecord.asNSRecord == nil)
        #expect(anyRecord.asPTRRecord == nil)
    }
    
    @Test("Handle unsupported DNS record type")
    func testListDNSRecords_UnsupportedRecordType() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "example.com",
                "type": "SOA", // Unsupported type
                "content": "ns1.example.com admin.example.com 2023010101 3600 1800 604800 86400",
                "ttl": 86400,
                "proxiable": false,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords),
            HTTPResponse(status: .ok)
        )
        
        do {
            _ = try await client.listDNSRecords(zoneId: "zone123")
            Issue.record("Expected error for unsupported record type")
        } catch DNSRequestError.networkError(let underlyingError) {
            if case DecodingError.dataCorrupted(let context) = underlyingError {
                #expect(context.debugDescription.contains("Unsupported DNS record type: SOA"))
            } else {
                Issue.record("Unexpected underlying error: \(underlyingError)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Combined Filter Tests
    
    @Test("List DNS records with combined filters")
    func testListDNSRecords_CombinedFilters() async throws {
        let client = createMockClient()
        
        let mockRecords = [
            [
                "id": "record1",
                "zone_id": "zone123",
                "zone_name": "example.com",
                "name": "api.example.com",
                "type": "A",
                "content": "192.168.1.1",
                "ttl": 300,
                "proxiable": true,
                "proxied": false,
                "locked": false,
                "created_on": "2023-01-01T00:00:00.000000Z",
                "modified_on": "2023-01-01T00:00:00.000000Z"
            ]
        ]
        
        client.httpClient.mockResponse = (
            createSuccessResponse(records: mockRecords),
            HTTPResponse(status: .ok)
        )
        
        let result = try await client.listDNSRecords(
            zoneId: "zone123",
            type: .a,
            name: "api.example.com",
            page: 1,
            perPage: 25
        )
        
        #expect(result.records.count == 1)
        #expect(result.records[0].type == .a)
        #expect(result.records[0].name == "api.example.com")
        
        // Verify all parameters are in the request URL
        let lastRequest = client.httpClient.lastRequest
        #expect(lastRequest != nil)
        let urlString = lastRequest!.url!.absoluteString
        #expect(urlString.contains("type=A"))
        #expect(urlString.contains("name=api.example.com"))
        #expect(urlString.contains("page=1"))
        #expect(urlString.contains("per_page=25"))
    }
}


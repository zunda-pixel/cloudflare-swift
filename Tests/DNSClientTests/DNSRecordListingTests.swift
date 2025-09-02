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
    
    @Test("List DNS records with HTTP error")
    func testListDNSRecords_HTTPError() async throws {
        let client = createMockClient()
        
        client.httpClient.mockResponse = (
            Data(),
            HTTPResponse(status: .internalServerError)
        )
        
        do {
            _ = try await client.listDNSRecords(zoneId: "zone123")
            Issue.record("Expected error for HTTP failure")
        } catch DNSRequestError.httpError(let statusCode) {
            #expect(statusCode == 500)
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

// MARK: - Mock HTTP Client

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var mockResponse: (Data, HTTPResponse)?
    var lastRequest: HTTPRequest?
    
    func execute(for request: HTTPRequest, from body: Data?) async throws -> (Data, HTTPResponse) {
        lastRequest = request
        
        guard let response = mockResponse else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock response set"])
        }
        
        return response
    }
}
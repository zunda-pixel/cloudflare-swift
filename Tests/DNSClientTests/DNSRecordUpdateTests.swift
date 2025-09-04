import Foundation
import HTTPClient
import HTTPTypes
import Testing

@testable import DNSClient

@Suite("DNS Record Update Tests")
struct DNSRecordUpdateTests {

  // MARK: - Test Helpers

  private func createMockClient() -> DNSClient<MockHTTPClient> {
    return DNSClient(apiToken: "test-token", httpClient: MockHTTPClient())
  }

  // MARK: - A Record Update Tests

  @Test("Update A record successfully")
  func testUpdateARecord_Success() async throws {
    let client = createMockClient()

    let updatedRecord = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "10.0.0.1",  // Updated IP address
      ttl: .seconds(600),  // Updated TTL
      proxiable: true,
      proxied: true,  // Updated proxy status
      locked: false,
      comment: "Updated A record",
      tags: ["updated", "test"],
      createdOn: nil,
      modifiedOn: nil
    )

    let mockResponse: [String: Any] = [
      "id": "record123",
      "zone_id": "zone123",
      "zone_name": "example.com",
      "name": "example.com",
      "type": "A",
      "content": "10.0.0.1",
      "ttl": 600,
      "proxiable": true,
      "proxied": true,
      "locked": false,
      "comment": "Updated A record",
      "tags": ["updated", "test"],
      "created_on": "2023-01-01T00:00:00.000000Z",
      "modified_on": "2023-01-02T00:00:00.000000Z",
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    let result = try await client.updateDNSRecord(
      zoneId: "zone123",
      recordId: "record123",
      record: updatedRecord
    )

    #expect(result.id == "record123")
    #expect(result.content == "10.0.0.1")
    #expect(result.ttl == .seconds(600))
    #expect(result.proxied == true)
    #expect(result.comment == "Updated A record")
    #expect(result.tags == ["updated", "test"])

    // Verify request was made correctly
    let lastRequest = client.httpClient.lastRequest
    #expect(lastRequest != nil)
    #expect(lastRequest!.method == .put)
    #expect(lastRequest!.url!.absoluteString.contains("zones/zone123/dns_records/record123"))
    #expect(lastRequest!.headerFields[.contentType] == "application/json")
  }

  @Test("Update AAAA record successfully")
  func testUpdateAAAARecord_Success() async throws {
    let client = createMockClient()

    let updatedRecord = AAAARecord(
      id: "record456",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "ipv6.example.com",
      content: "2001:db8::2",  // Updated IPv6 address
      ttl: .automatic,
      proxiable: true,
      proxied: false,
      locked: false,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    let mockResponse: [String: Any] = [
      "id": "record456",
      "zone_id": "zone123",
      "zone_name": "example.com",
      "name": "ipv6.example.com",
      "type": "AAAA",
      "content": "2001:db8::2",
      "ttl": 1,
      "proxiable": true,
      "proxied": false,
      "locked": false,
      "created_on": "2023-01-01T00:00:00.000000Z",
      "modified_on": "2023-01-02T00:00:00.000000Z",
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    let result = try await client.updateDNSRecord(
      zoneId: "zone123",
      recordId: "record456",
      record: updatedRecord
    )

    #expect(result.id == "record456")
    #expect(result.content == "2001:db8::2")
    #expect(result.ttl == .automatic)
    #expect(result.type == .aaaa)
  }

  @Test("Update CNAME record successfully")
  func testUpdateCNAMERecord_Success() async throws {
    let client = createMockClient()

    let updatedRecord = CNAMERecord(
      id: "record789",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "www.example.com",
      content: "new-target.example.com",  // Updated target
      ttl: .seconds(1800),
      proxiable: true,
      proxied: false,  // Updated proxy status
      locked: false,
      comment: "Updated CNAME",
      tags: ["cname", "updated"],
      createdOn: nil,
      modifiedOn: nil
    )

    let mockResponse: [String: Any] = [
      "id": "record789",
      "zone_id": "zone123",
      "zone_name": "example.com",
      "name": "www.example.com",
      "type": "CNAME",
      "content": "new-target.example.com",
      "ttl": 1800,
      "proxiable": true,
      "proxied": false,
      "locked": false,
      "comment": "Updated CNAME",
      "tags": ["cname", "updated"],
      "created_on": "2023-01-01T00:00:00.000000Z",
      "modified_on": "2023-01-02T00:00:00.000000Z",
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    let result = try await client.updateDNSRecord(
      zoneId: "zone123",
      recordId: "record789",
      record: updatedRecord
    )

    #expect(result.id == "record789")
    #expect(result.content == "new-target.example.com")
    #expect(result.ttl == .seconds(1800))
    #expect(result.proxied == false)
    #expect(result.comment == "Updated CNAME")
    #expect(result.tags == ["cname", "updated"])
  }

  // MARK: - Validation Tests

  @Test("Update record with invalid zone ID")
  func testUpdateRecord_InvalidZoneId() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "192.168.1.1",
      ttl: .seconds(300),
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    do {
      _ = try await client.updateDNSRecord(zoneId: "", recordId: "record123", record: record)
      Issue.record("Expected error for empty zone ID")
    } catch DNSRequestError.invalidZoneId {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Update record with invalid record ID")
  func testUpdateRecord_InvalidRecordId() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "192.168.1.1",
      ttl: .seconds(300),
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    do {
      _ = try await client.updateDNSRecord(zoneId: "zone123", recordId: "", record: record)
      Issue.record("Expected error for empty record ID")
    } catch DNSRequestError.recordNotFound {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Update record with invalid TTL")
  func testUpdateRecord_InvalidTTL() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "192.168.1.1",
      ttl: .seconds(30),  // Invalid TTL (too low)
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    do {
      _ = try await client.updateDNSRecord(zoneId: "zone123", recordId: "record123", record: record)
      Issue.record("Expected error for invalid TTL")
    } catch DNSRequestError.invalidTTL {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  // MARK: - Error Handling Tests

  @Test("Update record with record not found error")
  func testUpdateRecord_RecordNotFound() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: "nonexistent",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "192.168.1.1",
      ttl: .seconds(300),
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    let errors = [
      [
        "code": 81044,
        "message": "DNS record not found",
      ]
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createErrorResponse(errors: errors),
      HTTPResponse(status: .notFound)
    )

    do {
      _ = try await client.updateDNSRecord(
        zoneId: "zone123", recordId: "nonexistent", record: record)
      Issue.record("Expected error for record not found")
    } catch DNSRequestError.recordNotFound {
      // Expected error based on error code mapping
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Update record with validation error")
  func testUpdateRecord_ValidationError() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "invalid-ip",
      ttl: .seconds(300),
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    let errors = [
      [
        "code": 1007,
        "message": "Invalid IP address format",
      ]
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createErrorResponse(errors: errors),
      HTTPResponse(status: .badRequest)
    )

    do {
      _ = try await client.updateDNSRecord(zoneId: "zone123", recordId: "record123", record: record)
      Issue.record("Expected error for invalid IP address")
    } catch DNSRequestError.invalidIPAddress {
      // Expected error based on error code mapping
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Update record with network error")
  func testUpdateRecord_NetworkError() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "192.168.1.1",
      ttl: .seconds(300),
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: nil,
      tags: nil,
      createdOn: nil,
      modifiedOn: nil
    )

    // Return invalid JSON to simulate network/parsing error
    client.httpClient.mockResponse = (
      Data("invalid json".utf8),
      HTTPResponse(status: .internalServerError)
    )

    do {
      _ = try await client.updateDNSRecord(zoneId: "zone123", recordId: "record123", record: record)
      Issue.record("Expected error for network failure")
    } catch DNSRequestError.networkError {
      // Expected error for JSON parsing failure
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  // MARK: - Partial Update Tests

  @Test("Update record with partial changes")
  func testUpdateRecord_PartialUpdate() async throws {
    let client = createMockClient()

    // Only updating content and comment, keeping other fields the same
    let updatedRecord = ARecord(
      id: "record123",
      zoneId: "zone123",
      zoneName: "example.com",
      name: "example.com",
      content: "203.0.113.1",  // Only this changed
      ttl: .seconds(300),  // Same as before
      proxiable: true,
      proxied: false,  // Same as before
      locked: false,
      comment: "Partially updated record",  // Only this changed
      tags: ["test"],  // Same as before
      createdOn: nil,
      modifiedOn: nil
    )

    let mockResponse: [String: Any] = [
      "id": "record123",
      "zone_id": "zone123",
      "zone_name": "example.com",
      "name": "example.com",
      "type": "A",
      "content": "203.0.113.1",
      "ttl": 300,
      "proxiable": true,
      "proxied": false,
      "locked": false,
      "comment": "Partially updated record",
      "tags": ["test"],
      "created_on": "2023-01-01T00:00:00.000000Z",
      "modified_on": "2023-01-02T00:00:00.000000Z",
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    let result = try await client.updateDNSRecord(
      zoneId: "zone123",
      recordId: "record123",
      record: updatedRecord
    )

    #expect(result.content == "203.0.113.1")
    #expect(result.comment == "Partially updated record")
    #expect(result.ttl == .seconds(300))
    #expect(result.proxied == false)

    // Verify request body contains the updated record
    #expect(client.httpClient.lastRequestBody != nil)
    let sentData = client.httpClient.lastRequestBody!
    let decodedRecord = try JSONDecoder().decode(ARecord.self, from: sentData)
    #expect(decodedRecord.content == "203.0.113.1")
    #expect(decodedRecord.comment == "Partially updated record")
  }
}

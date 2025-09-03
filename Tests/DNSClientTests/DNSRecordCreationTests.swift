import Foundation
import HTTPClient
import HTTPTypes
import Testing

@testable import DNSClient

@Suite("DNS Record Creation Tests")
struct DNSRecordCreationTests {

  // MARK: - Test Helpers

  private func createMockClient() -> DNSClient<MockHTTPClient> {
    return DNSClient(apiToken: "test-token", httpClient: MockHTTPClient())
  }

  // MARK: - A Record Creation Tests

  @Test("Create A record successfully")
  func testCreateARecord_Success() async throws {
    let client = createMockClient()

    let inputRecord = ARecord(
      id: nil,
      zoneId: nil,
      zoneName: nil,
      name: "example.com",
      content: "192.168.1.1",
      ttl: .seconds(300),
      proxiable: nil,
      proxied: false,
      locked: nil,
      comment: "Test A record",
      tags: ["test"],
      createdOn: nil,
      modifiedOn: nil
    )

    let mockResponse: [String: Any] = [
      "id": "record123",
      "zone_id": "zone123",
      "zone_name": "example.com",
      "name": "example.com",
      "type": "A",
      "content": "192.168.1.1",
      "ttl": 300,
      "proxiable": true,
      "proxied": false,
      "locked": false,
      "comment": "Test A record",
      "tags": ["test"],
      "created_on": "2023-01-01T00:00:00.000000Z",
      "modified_on": "2023-01-01T00:00:00.000000Z"
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    let createdRecord = try await client.createDNSRecord(zoneId: "zone123", record: inputRecord)

    #expect(createdRecord.id == "record123")
    #expect(createdRecord.zoneId == "zone123")
    #expect(createdRecord.name == "example.com")
    #expect(createdRecord.content == "192.168.1.1")
    #expect(createdRecord.type == .a)
    #expect(createdRecord.ttl == .seconds(300))
    #expect(createdRecord.comment == "Test A record")
    #expect(createdRecord.tags == ["test"])

    // Verify request was made correctly
    let lastRequest = client.httpClient.lastRequest
    #expect(lastRequest != nil)
    #expect(lastRequest!.method == .post)
    #expect(lastRequest!.url!.absoluteString.contains("zones/zone123/dns_records"))
    #expect(lastRequest!.headerFields[.contentType] == "application/json")
  }

  // MARK: - Validation Tests

  @Test("Create record with invalid zone ID")
  func testCreateRecord_InvalidZoneId() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: nil,
      zoneId: nil,
      zoneName: nil,
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
      _ = try await client.createDNSRecord(zoneId: "", record: record)
      Issue.record("Expected error for empty zone ID")
    } catch DNSRequestError.invalidZoneId {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Create record with invalid TTL")
  func testCreateRecord_InvalidTTL() async throws {
    let client = createMockClient()

    let record = ARecord(
      id: nil,
      zoneId: nil,
      zoneName: nil,
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
      _ = try await client.createDNSRecord(zoneId: "zone123", record: record)
      Issue.record("Expected error for invalid TTL")
    } catch DNSRequestError.invalidTTL {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }
}

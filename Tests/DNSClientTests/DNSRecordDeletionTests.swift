import Foundation
import HTTPClient
import HTTPTypes
import Testing

@testable import DNSClient

@Suite("DNS Record Deletion Tests")
struct DNSRecordDeletionTests {

  // MARK: - Test Helpers

  private func createMockClient() -> DNSClient<MockHTTPClient> {
    return DNSClient(apiToken: "test-token", httpClient: MockHTTPClient())
  }

  // MARK: - Successful Deletion Tests

  @Test("Delete DNS record successfully")
  func testDeleteRecord_Success() async throws {
    let client = createMockClient()

    let mockResponse: [String: Any] = [
      "id": "record123"
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    let result = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "record123")

    #expect(result.id == "record123")

    // Verify request was made correctly
    let lastRequest = client.httpClient.lastRequest
    #expect(lastRequest != nil)
    #expect(lastRequest!.method == .delete)
    #expect(lastRequest!.url!.absoluteString.contains("zones/zone123/dns_records/record123"))

    // Verify no request body was sent for DELETE
    #expect(client.httpClient.lastRequestBody == nil)
  }

  @Test("Delete multiple different records")
  func testDeleteRecord_MultipleRecords() async throws {
    let client = createMockClient()

    // Test deleting first record
    let mockResponse1: [String: Any] = ["id": "record456"]
    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse1),
      HTTPResponse(status: .ok)
    )

    let result1 = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "record456")
    #expect(result1.id == "record456")

    // Test deleting second record
    let mockResponse2: [String: Any] = ["id": "record789"]
    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse2),
      HTTPResponse(status: .ok)
    )

    let result2 = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "record789")
    #expect(result2.id == "record789")

    // Verify the last request was for the second record
    let lastRequest = client.httpClient.lastRequest
    #expect(lastRequest!.url!.absoluteString.contains("record789"))
  }

  // MARK: - Validation Tests

  @Test("Delete record with invalid zone ID")
  func testDeleteRecord_InvalidZoneId() async throws {
    let client = createMockClient()

    do {
      _ = try await client.deleteDNSRecord(zoneId: "", recordId: "record123")
      Issue.record("Expected error for empty zone ID")
    } catch DNSRequestError.invalidZoneId {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Delete record with invalid record ID")
  func testDeleteRecord_InvalidRecordId() async throws {
    let client = createMockClient()

    do {
      _ = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "")
      Issue.record("Expected error for empty record ID")
    } catch DNSRequestError.recordNotFound {
      // Expected error
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  // MARK: - Error Handling Tests

  @Test("Delete record with record not found error")
  func testDeleteRecord_RecordNotFound() async throws {
    let client = createMockClient()

    let errors = [
      [
        "code": 81044,
        "message": "DNS record not found"
      ]
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createErrorResponse(errors: errors),
      HTTPResponse(status: .notFound)
    )

    do {
      _ = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "nonexistent")
      Issue.record("Expected error for record not found")
    } catch DNSRequestError.recordNotFound {
      // Expected error based on error code mapping
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Delete record with invalid zone error")
  func testDeleteRecord_InvalidZone() async throws {
    let client = createMockClient()

    let errors = [
      [
        "code": 1003,
        "message": "Invalid zone identifier"
      ]
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createErrorResponse(errors: errors),
      HTTPResponse(status: .badRequest)
    )

    do {
      _ = try await client.deleteDNSRecord(zoneId: "invalid-zone", recordId: "record123")
      Issue.record("Expected error for invalid zone")
    } catch DNSRequestError.invalidZoneId {
      // Expected error based on error code mapping
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Delete record with authentication error")
  func testDeleteRecord_AuthenticationError() async throws {
    let client = createMockClient()

    let errors = [
      [
        "code": 10000,
        "message": "Invalid API token"
      ]
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createErrorResponse(errors: errors),
      HTTPResponse(status: .unauthorized)
    )

    do {
      _ = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "record123")
      Issue.record("Expected error for authentication failure")
    } catch DNSRequestError.invalidAuthentication {
      // Expected error based on error code mapping
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Delete record with network error")
  func testDeleteRecord_NetworkError() async throws {
    let client = createMockClient()

    // Return invalid JSON to simulate network/parsing error
    client.httpClient.mockResponse = (
      Data("invalid json".utf8),
      HTTPResponse(status: .internalServerError)
    )

    do {
      _ = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "record123")
      Issue.record("Expected error for network failure")
    } catch DNSRequestError.networkError {
      // Expected error for JSON parsing failure
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Delete record with unknown error")
  func testDeleteRecord_UnknownError() async throws {
    let client = createMockClient()

    let errors = [
      [
        "code": 99999,
        "message": "Unknown error occurred"
      ]
    ]

    client.httpClient.mockResponse = (
      MockHTTPClient.createErrorResponse(errors: errors),
      HTTPResponse(status: .internalServerError)
    )

    do {
      _ = try await client.deleteDNSRecord(zoneId: "zone123", recordId: "record123")
      Issue.record("Expected error for unknown failure")
    } catch DNSRequestError.unknown(let errorMessages) {
      // Expected error for unmapped error codes
      #expect(errorMessages.count == 1)
      #expect(errorMessages[0].code == 99999)
      #expect(errorMessages[0].message == "Unknown error occurred")
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  // MARK: - URL Construction Tests

  @Test("Verify correct URL construction for deletion")
  func testDeleteRecord_URLConstruction() async throws {
    let client = createMockClient()

    let mockResponse: [String: Any] = ["id": "test-record-id"]
    client.httpClient.mockResponse = (
      MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
      HTTPResponse(status: .ok)
    )

    _ = try await client.deleteDNSRecord(zoneId: "test-zone-id", recordId: "test-record-id")

    let lastRequest = client.httpClient.lastRequest
    #expect(lastRequest != nil)

    let expectedURLPath = "zones/test-zone-id/dns_records/test-record-id"
    #expect(lastRequest!.url!.absoluteString.contains(expectedURLPath))
    #expect(lastRequest!.method == .delete)
  }

  // MARK: - Response Parsing Tests

  @Test("Parse deletion response correctly")
  func testDeleteRecord_ResponseParsing() async throws {
    let client = createMockClient()

    // Test with different record ID formats
    let testCases = [
      "simple-id",
      "complex-id-with-dashes-123",
      "1234567890abcdef",
      "record_with_underscores"
    ]

    for recordId in testCases {
      let mockResponse: [String: Any] = ["id": recordId]
      client.httpClient.mockResponse = (
        MockHTTPClient.createSuccessResponse(dictionary: mockResponse),
        HTTPResponse(status: .ok)
      )

      let result = try await client.deleteDNSRecord(zoneId: "zone123", recordId: recordId)
      #expect(result.id == recordId)
    }
  }
}

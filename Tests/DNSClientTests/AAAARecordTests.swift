import Foundation
import Testing

@testable import DNSClient

@Suite("AAAARecord Tests")
struct AAAARecordTests {

  @Test("AAAARecord initialization")
  func testAAAARecordInitialization() {
    let record = AAAARecord(
      id: "test-id",
      zoneId: "zone-123",
      zoneName: "example.com",
      name: "www.example.com",
      content: "2001:db8::1",
      ttl: .seconds(3600),
      proxiable: true,
      proxied: false,
      comment: "Test AAAA record"
    )

    #expect(record.id == "test-id")
    #expect(record.zoneId == "zone-123")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "www.example.com")
    #expect(record.type == .aaaa)
    #expect(record.content == "2001:db8::1")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == true)
    #expect(record.proxied == false)
    #expect(record.comment == "Test AAAA record")
  }

  @Test("AAAARecord minimal initialization")
  func testAAAARecordMinimalInitialization() {
    let record = AAAARecord(
      name: "example.com",
      content: "::1",
      ttl: .automatic
    )

    #expect(record.id == nil)
    #expect(record.zoneId == nil)
    #expect(record.zoneName == nil)
    #expect(record.name == "example.com")
    #expect(record.type == .aaaa)
    #expect(record.content == "::1")
    #expect(record.ttl == .automatic)
    #expect(record.proxiable == nil)
    #expect(record.proxied == nil)
    #expect(record.comment == nil)
  }

  @Test("IPv6 address validation - valid addresses")
  func testValidIPv6Addresses() {
    let validAddresses = [
      "2001:db8:85a3:0:0:8a2e:370:7334",  // Full format
      "2001:db8:85a3::8a2e:370:7334",  // Compressed zeros
      "2001:db8::1",  // Compressed trailing zeros
      "::1",  // Loopback
      "::",  // All zeros
      "2001:db8::",  // Compressed at end
      "::2001:db8",  // Compressed at start
      "fe80::1%lo0",  // Link-local (note: % not validated in this simple implementation)
      "2001:0db8:85a3:0000:0000:8a2e:0370:7334",  // Full with leading zeros
      "2001:db8:85a3:0:0:8a2e:370:7334",  // Mixed compression
      "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",  // All F's
    ]

    for address in validAddresses {
      // Skip addresses with % for this simple validation
      if address.contains("%") { continue }

      #expect(AAAARecord.isValidIPv6Address(address) == true, "Address \(address) should be valid")

      let record = AAAARecord(name: "test.com", content: address, ttl: .automatic)
      #expect(record.isValidIPv6 == true, "Record with address \(address) should be valid")
    }
  }

  @Test("IPv6 address validation - invalid addresses")
  func testInvalidIPv6Addresses() {
    let invalidAddresses = [
      "2001:db8:85a3:0:0:8a2e:370:7334:extra",  // Too many groups
      "2001:db8:85a3:0:0:8a2e:370",  // Too few groups
      "2001:db8::85a3::370",  // Multiple ::
      "2001:db8:85a3:0:0:8a2e:370g:7334",  // Invalid hex character
      "2001:db8:85a3:0:0:8a2e:37000:7334",  // Group too long
      "",  // Empty string
      ":",  // Single colon
      ":::",  // Triple colon
      "2001:db8:85a3:0:0:8a2e::370:7334",  // :: with too many groups
      "2001::db8::1",  // Multiple ::
      "gggg::1",  // Invalid hex
      "2001:db8:85a3:0:0:8a2e:370:",  // Trailing colon
      ":2001:db8:85a3:0:0:8a2e:370:7334",  // Leading colon
      "2001.db8.85a3.0.0.8a2e.370.7334",  // Dots instead of colons
      "192.168.1.1",  // IPv4 address
      "2001:db8:85a3:0:0:8a2e:370:7334/64",  // CIDR notation
    ]

    for address in invalidAddresses {
      #expect(
        AAAARecord.isValidIPv6Address(address) == false, "Address \(address) should be invalid")

      let record = AAAARecord(name: "test.com", content: address, ttl: .automatic)
      #expect(record.isValidIPv6 == false, "Record with address \(address) should be invalid")
    }
  }

  @Test("IPv6 address validation - edge cases")
  func testIPv6EdgeCases() {
    // Test boundary cases for compression
    let edgeCases = [
      ("2001:db8:0:0:0:0:0:1", true),  // Could be compressed but isn't
      ("2001:db8::0:0:1", true),  // Partial compression
      ("0:0:0:0:0:0:0:1", true),  // Could be ::1 but isn't
      ("0000:0000:0000:0000:0000:0000:0000:0001", true),  // Full zeros with leading
    ]

    for (address, expected) in edgeCases {
      #expect(
        AAAARecord.isValidIPv6Address(address) == expected,
        "Address \(address) validation should be \(expected)")
    }
  }

  @Test("AAAARecord JSON serialization")
  func testAAAARecordJSONSerialization() throws {
    let record = AAAARecord(
      id: "372e67954025e0ba6aaa6d586b9e0b59",
      zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
      zoneName: "example.com",
      name: "www.example.com",
      content: "2001:db8::1",
      ttl: .seconds(3600),
      proxiable: true,
      proxied: false,
      locked: false,
      comment: "Test AAAA record",
      tags: ["production", "ipv6"],
      createdOn: Date(timeIntervalSince1970: 1_609_459_200),  // 2021-01-01 00:00:00 UTC
      modifiedOn: Date(timeIntervalSince1970: 1_609_545_600)  // 2021-01-02 00:00:00 UTC
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(record)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    #expect(json["id"] as? String == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(json["zone_id"] as? String == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(json["zone_name"] as? String == "example.com")
    #expect(json["name"] as? String == "www.example.com")
    #expect(json["type"] as? String == "AAAA")
    #expect(json["content"] as? String == "2001:db8::1")
    #expect(json["ttl"] as? Int == 3600)
    #expect(json["proxiable"] as? Bool == true)
    #expect(json["proxied"] as? Bool == false)
    #expect(json["locked"] as? Bool == false)
    #expect(json["comment"] as? String == "Test AAAA record")

    let tags = json["tags"] as? [String]
    #expect(tags?.count == 2)
    #expect(tags?.contains("production") == true)
    #expect(tags?.contains("ipv6") == true)
  }

  @Test("AAAARecord JSON deserialization")
  func testAAAARecordJSONDeserialization() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
          "zone_name": "example.com",
          "name": "www.example.com",
          "type": "AAAA",
          "content": "2001:db8::1",
          "ttl": 3600,
          "proxiable": true,
          "proxied": false,
          "locked": false,
          "comment": "Test AAAA record",
          "tags": ["production", "ipv6"],
          "created_on": "2021-01-01T00:00:00Z",
          "modified_on": "2021-01-02T00:00:00Z"
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let record = try decoder.decode(AAAARecord.self, from: data)

    #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "www.example.com")
    #expect(record.type == .aaaa)
    #expect(record.content == "2001:db8::1")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == true)
    #expect(record.proxied == false)
    #expect(record.locked == false)
    #expect(record.comment == "Test AAAA record")
    #expect(record.tags?.count == 2)
    #expect(record.tags?.contains("production") == true)
    #expect(record.tags?.contains("ipv6") == true)
  }

  @Test("AAAARecord JSON deserialization with automatic TTL")
  func testAAAARecordJSONDeserializationAutomaticTTL() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "name": "example.com",
          "type": "AAAA",
          "content": "::1",
          "ttl": 1
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()

    let record = try decoder.decode(AAAARecord.self, from: data)

    #expect(record.ttl == .automatic)
    #expect(record.content == "::1")
    #expect(record.isValidIPv6 == true)
  }

  @Test("AAAARecord hashable conformance")
  func testAAAARecordHashable() {
    let record1 = AAAARecord(
      id: "test-id",
      name: "example.com",
      content: "2001:db8::1",
      ttl: .seconds(3600)
    )

    let record2 = AAAARecord(
      id: "test-id",
      name: "example.com",
      content: "2001:db8::1",
      ttl: .seconds(3600)
    )

    let record3 = AAAARecord(
      id: "different-id",
      name: "example.com",
      content: "2001:db8::1",
      ttl: .seconds(3600)
    )

    #expect(record1 == record2)
    #expect(record1 != record3)
    #expect(record1.hashValue == record2.hashValue)
  }

  @Test("AAAARecord edge cases")
  func testAAAARecordEdgeCases() {
    // Test with empty optional fields
    let record = AAAARecord(
      name: "test.example.com",
      content: "2001:db8:85a3::8a2e:370:7334",
      ttl: .seconds(300),
      tags: []
    )

    #expect(record.tags?.isEmpty == true)
    #expect(record.isValidIPv6 == true)

    // Test with loopback address
    let loopbackRecord = AAAARecord(name: "localhost", content: "::1", ttl: .automatic)
    #expect(loopbackRecord.isValidIPv6 == true)

    // Test with all zeros
    let zeroRecord = AAAARecord(name: "test.com", content: "::", ttl: .automatic)
    #expect(zeroRecord.isValidIPv6 == true)
  }
}

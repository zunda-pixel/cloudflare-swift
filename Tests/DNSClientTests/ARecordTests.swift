import Foundation
import Testing

@testable import DNSClient

@Suite("ARecord Tests")
struct ARecordTests {

  @Test("ARecord initialization")
  func testARecordInitialization() {
    let record = ARecord(
      id: "test-id",
      zoneId: "zone-123",
      zoneName: "example.com",
      name: "www.example.com",
      content: "192.168.1.1",
      ttl: .seconds(3600),
      proxiable: true,
      proxied: false,
      comment: "Test A record"
    )

    #expect(record.id == "test-id")
    #expect(record.zoneId == "zone-123")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "www.example.com")
    #expect(record.type == .a)
    #expect(record.content == "192.168.1.1")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == true)
    #expect(record.proxied == false)
    #expect(record.comment == "Test A record")
  }

  @Test("ARecord minimal initialization")
  func testARecordMinimalInitialization() {
    let record = ARecord(
      name: "example.com",
      content: "10.0.0.1",
      ttl: .automatic
    )

    #expect(record.id == nil)
    #expect(record.zoneId == nil)
    #expect(record.zoneName == nil)
    #expect(record.name == "example.com")
    #expect(record.type == .a)
    #expect(record.content == "10.0.0.1")
    #expect(record.ttl == .automatic)
    #expect(record.proxiable == nil)
    #expect(record.proxied == nil)
    #expect(record.comment == nil)
  }

  @Test("IPv4 address validation - valid addresses")
  func testValidIPv4Addresses() {
    let validAddresses = [
      "0.0.0.0",
      "127.0.0.1",
      "192.168.1.1",
      "10.0.0.1",
      "172.16.0.1",
      "8.8.8.8",
      "255.255.255.255",
      "1.2.3.4"
    ]

    for address in validAddresses {
      #expect(ARecord.isValidIPv4Address(address) == true, "Address \(address) should be valid")

      let record = ARecord(name: "test.com", content: address, ttl: .automatic)
      #expect(record.isValidIPv4 == true, "Record with address \(address) should be valid")
    }
  }

  @Test("IPv4 address validation - invalid addresses")
  func testInvalidIPv4Addresses() {
    let invalidAddresses = [
      "256.1.1.1",  // Component > 255
      "1.256.1.1",  // Component > 255
      "1.1.256.1",  // Component > 255
      "1.1.1.256",  // Component > 255
      "1.1.1",  // Too few components
      "1.1.1.1.1",  // Too many components
      "1.1.1.-1",  // Negative component
      "1.1.1.01",  // Leading zero
      "1.1.1.a",  // Non-numeric component
      "",  // Empty string
      "1.1.1.",  // Trailing dot
      ".1.1.1",  // Leading dot
      "1..1.1",  // Double dot
      "192.168.1.1.1",  // Too many octets
      "192.168.1",  // Too few octets
      "abc.def.ghi.jkl",  // All non-numeric
      "192.168.1.1/24",  // CIDR notation
      "192.168.1.1:80"  // With port
    ]

    for address in invalidAddresses {
      #expect(ARecord.isValidIPv4Address(address) == false, "Address \(address) should be invalid")

      let record = ARecord(name: "test.com", content: address, ttl: .automatic)
      #expect(record.isValidIPv4 == false, "Record with address \(address) should be invalid")
    }
  }

  @Test("ARecord JSON serialization")
  func testARecordJSONSerialization() throws {
    let record = ARecord(
      id: "372e67954025e0ba6aaa6d586b9e0b59",
      zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
      zoneName: "example.com",
      name: "www.example.com",
      content: "192.0.2.1",
      ttl: .seconds(3600),
      proxiable: true,
      proxied: false,
      locked: false,
      comment: "Test A record",
      tags: ["production", "web"],
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
    #expect(json["type"] as? String == "A")
    #expect(json["content"] as? String == "192.0.2.1")
    #expect(json["ttl"] as? Int == 3600)
    #expect(json["proxiable"] as? Bool == true)
    #expect(json["proxied"] as? Bool == false)
    #expect(json["locked"] as? Bool == false)
    #expect(json["comment"] as? String == "Test A record")

    let tags = json["tags"] as? [String]
    #expect(tags?.count == 2)
    #expect(tags?.contains("production") == true)
    #expect(tags?.contains("web") == true)
  }

  @Test("ARecord JSON deserialization")
  func testARecordJSONDeserialization() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
          "zone_name": "example.com",
          "name": "www.example.com",
          "type": "A",
          "content": "192.0.2.1",
          "ttl": 3600,
          "proxiable": true,
          "proxied": false,
          "locked": false,
          "comment": "Test A record",
          "tags": ["production", "web"],
          "created_on": "2021-01-01T00:00:00Z",
          "modified_on": "2021-01-02T00:00:00Z"
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let record = try decoder.decode(ARecord.self, from: data)

    #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "www.example.com")
    #expect(record.type == .a)
    #expect(record.content == "192.0.2.1")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == true)
    #expect(record.proxied == false)
    #expect(record.locked == false)
    #expect(record.comment == "Test A record")
    #expect(record.tags?.count == 2)
    #expect(record.tags?.contains("production") == true)
    #expect(record.tags?.contains("web") == true)
  }

  @Test("ARecord JSON deserialization with automatic TTL")
  func testARecordJSONDeserializationAutomaticTTL() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "name": "example.com",
          "type": "A",
          "content": "192.0.2.1",
          "ttl": 1
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()

    let record = try decoder.decode(ARecord.self, from: data)

    #expect(record.ttl == .automatic)
    #expect(record.content == "192.0.2.1")
    #expect(record.isValidIPv4 == true)
  }

  @Test("ARecord hashable conformance")
  func testARecordHashable() {
    let record1 = ARecord(
      id: "test-id",
      name: "example.com",
      content: "192.0.2.1",
      ttl: .seconds(3600)
    )

    let record2 = ARecord(
      id: "test-id",
      name: "example.com",
      content: "192.0.2.1",
      ttl: .seconds(3600)
    )

    let record3 = ARecord(
      id: "different-id",
      name: "example.com",
      content: "192.0.2.1",
      ttl: .seconds(3600)
    )

    #expect(record1 == record2)
    #expect(record1 != record3)
    #expect(record1.hashValue == record2.hashValue)
  }

  @Test("ARecord edge cases")
  func testARecordEdgeCases() {
    // Test with empty optional fields
    let record = ARecord(
      name: "test.example.com",
      content: "203.0.113.1",
      ttl: .seconds(300),
      tags: []
    )

    #expect(record.tags?.isEmpty == true)
    #expect(record.isValidIPv4 == true)

    // Test with all boundary IP addresses
    let boundaryRecord1 = ARecord(name: "test.com", content: "0.0.0.0", ttl: .automatic)
    #expect(boundaryRecord1.isValidIPv4 == true)

    let boundaryRecord2 = ARecord(name: "test.com", content: "255.255.255.255", ttl: .automatic)
    #expect(boundaryRecord2.isValidIPv4 == true)
  }
}

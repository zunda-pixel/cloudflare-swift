import Foundation
import Testing

@testable import DNSClient

@Suite("MXRecord Tests")
struct MXRecordTests {

  @Test("MXRecord initialization")
  func testMXRecordInitialization() {
    let record = MXRecord(
      id: "test-id",
      zoneId: "zone-123",
      zoneName: "example.com",
      name: "example.com",
      content: "mail.example.com",
      priority: 10,
      ttl: .seconds(3600),
      comment: "Test MX record"
    )

    #expect(record.id == "test-id")
    #expect(record.zoneId == "zone-123")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "example.com")
    #expect(record.type == .mx)
    #expect(record.content == "mail.example.com")
    #expect(record.priority == 10)
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.comment == "Test MX record")
    #expect(record.data?.priority == 10)
    #expect(record.data?.target == "mail.example.com")
  }

  @Test("MXRecord minimal initialization")
  func testMXRecordMinimalInitialization() {
    let record = MXRecord(
      name: "example.com",
      content: "mail.example.com",
      priority: 5,
      ttl: .automatic
    )

    #expect(record.id == nil)
    #expect(record.zoneId == nil)
    #expect(record.zoneName == nil)
    #expect(record.name == "example.com")
    #expect(record.type == .mx)
    #expect(record.content == "mail.example.com")
    #expect(record.priority == 5)
    #expect(record.ttl == .automatic)
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.comment == nil)
    #expect(record.data?.priority == 5)
    #expect(record.data?.target == "mail.example.com")
  }

  @Test("MX priority validation - valid priorities")
  func testValidMXPriorities() {
    let validPriorities = [0, 1, 5, 10, 20, 50, 100, 1000, 32767, 65535]

    for priority in validPriorities {
      let record = MXRecord(
        name: "example.com",
        content: "mail.example.com",
        priority: priority,
        ttl: .automatic
      )
      #expect(record.isValidPriority == true, "Priority \(priority) should be valid")
      #expect(record.data?.isValidPriority == true, "MXData priority \(priority) should be valid")
    }
  }

  @Test("MX priority validation - invalid priorities")
  func testInvalidMXPriorities() {
    let invalidPriorities = [-1, -10, 65536, 100000]

    for priority in invalidPriorities {
      let record = MXRecord(
        name: "example.com",
        content: "mail.example.com",
        priority: priority,
        ttl: .automatic
      )
      #expect(record.isValidPriority == false, "Priority \(priority) should be invalid")
      #expect(
        record.data?.isValidPriority == false, "MXData priority \(priority) should be invalid")
    }
  }

  @Test("Hostname validation - valid hostnames")
  func testValidHostnames() {
    let validHostnames = [
      "mail.example.com",
      "mx1.example.org",
      "backup-mail.example.net",
      "mail123.example.co.uk",
      "a.b.c.d.example.com",
      "mail.sub.domain.example.com",
      "mx-server.example.com",
      "1mail.example.com",
      "mail1.example.com"
    ]

    for hostname in validHostnames {
      #expect(MXRecord.isValidHostname(hostname) == true, "Hostname \(hostname) should be valid")

      let record = MXRecord(
        name: "example.com",
        content: hostname,
        priority: 10,
        ttl: .automatic
      )
      #expect(record.isValidHostname == true, "Record with hostname \(hostname) should be valid")
      #expect(record.data?.isValidTarget == true, "MXData with target \(hostname) should be valid")
    }
  }

  @Test("Hostname validation - invalid hostnames")
  func testInvalidHostnames() {
    let invalidHostnames = [
      "",  // Empty string
      ".",  // Just a dot
      ".example.com",  // Leading dot
      "mail..example.com",  // Double dot
      "-mail.example.com",  // Leading hyphen
      "mail-.example.com",  // Trailing hyphen
      "mail.example-.com",  // Trailing hyphen in component
      "mail.example.com-",  // Trailing hyphen at end
      "mail@example.com",  // Invalid character
      "mail example.com",  // Space
      "mail.example.com/path",  // Slash
      "mail.example.com:25"  // Port number
    ]

    for hostname in invalidHostnames {
      #expect(MXRecord.isValidHostname(hostname) == false, "Hostname \(hostname) should be invalid")

      let record = MXRecord(
        name: "example.com",
        content: hostname,
        priority: 10,
        ttl: .automatic
      )
      #expect(record.isValidHostname == false, "Record with hostname \(hostname) should be invalid")
    }
  }

  @Test("MXRecord JSON serialization")
  func testMXRecordJSONSerialization() throws {
    let mxData = MXData(priority: 10, target: "mail.example.com")
    let record = MXRecord(
      id: "372e67954025e0ba6aaa6d586b9e0b59",
      zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
      zoneName: "example.com",
      name: "example.com",
      content: "mail.example.com",
      priority: 10,
      data: mxData,
      ttl: .seconds(3600),
      locked: false,
      comment: "Primary mail server",
      tags: ["mail", "production"],
      createdOn: Date(timeIntervalSince1970: 1_609_459_200),
      modifiedOn: Date(timeIntervalSince1970: 1_609_545_600)
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(record)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    #expect(json["id"] as? String == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(json["zone_id"] as? String == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(json["zone_name"] as? String == "example.com")
    #expect(json["name"] as? String == "example.com")
    #expect(json["type"] as? String == "MX")
    #expect(json["content"] as? String == "mail.example.com")
    #expect(json["priority"] as? Int == 10)
    #expect(json["ttl"] as? Int == 3600)
    #expect(json["proxiable"] as? Bool == false)
    #expect(json["proxied"] as? Bool == false)
    #expect(json["locked"] as? Bool == false)
    #expect(json["comment"] as? String == "Primary mail server")

    let tags = json["tags"] as? [String]
    #expect(tags?.count == 2)
    #expect(tags?.contains("mail") == true)
    #expect(tags?.contains("production") == true)

    let dataDict = json["data"] as? [String: Any]
    #expect(dataDict?["priority"] as? Int == 10)
    #expect(dataDict?["target"] as? String == "mail.example.com")
  }

  @Test("MXRecord JSON deserialization")
  func testMXRecordJSONDeserialization() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
          "zone_name": "example.com",
          "name": "example.com",
          "type": "MX",
          "content": "mail.example.com",
          "priority": 10,
          "data": {
              "priority": 10,
              "target": "mail.example.com"
          },
          "ttl": 3600,
          "proxiable": false,
          "proxied": false,
          "locked": false,
          "comment": "Primary mail server",
          "tags": ["mail", "production"],
          "created_on": "2021-01-01T00:00:00Z",
          "modified_on": "2021-01-02T00:00:00Z"
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let record = try decoder.decode(MXRecord.self, from: data)

    #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "example.com")
    #expect(record.type == .mx)
    #expect(record.content == "mail.example.com")
    #expect(record.priority == 10)
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.locked == false)
    #expect(record.comment == "Primary mail server")
    #expect(record.tags?.count == 2)
    #expect(record.tags?.contains("mail") == true)
    #expect(record.tags?.contains("production") == true)
    #expect(record.data?.priority == 10)
    #expect(record.data?.target == "mail.example.com")
  }

  @Test("MXRecord hashable conformance")
  func testMXRecordHashable() {
    let record1 = MXRecord(
      id: "test-id",
      name: "example.com",
      content: "mail.example.com",
      priority: 10,
      ttl: .seconds(3600)
    )

    let record2 = MXRecord(
      id: "test-id",
      name: "example.com",
      content: "mail.example.com",
      priority: 10,
      ttl: .seconds(3600)
    )

    let record3 = MXRecord(
      id: "different-id",
      name: "example.com",
      content: "mail.example.com",
      priority: 10,
      ttl: .seconds(3600)
    )

    #expect(record1 == record2)
    #expect(record1 != record3)
    #expect(record1.hashValue == record2.hashValue)
  }
}

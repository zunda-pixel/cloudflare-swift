import Foundation
import Testing

@testable import DNSClient

@Suite("PTRRecord Tests")
struct PTRRecordTests {

  @Test("PTRRecord initialization")
  func testPTRRecordInitialization() {
    let record = PTRRecord(
      id: "test-id",
      zoneId: "zone-123",
      zoneName: "1.0.0.127.in-addr.arpa",
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com",
      ttl: .seconds(3600),
      comment: "Localhost PTR record"
    )

    #expect(record.id == "test-id")
    #expect(record.zoneId == "zone-123")
    #expect(record.zoneName == "1.0.0.127.in-addr.arpa")
    #expect(record.name == "1.0.0.127.in-addr.arpa")
    #expect(record.type == .ptr)
    #expect(record.content == "localhost.example.com")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.comment == "Localhost PTR record")
  }

  @Test("PTRRecord minimal initialization")
  func testPTRRecordMinimalInitialization() {
    let record = PTRRecord(
      name: "1.168.192.in-addr.arpa",
      content: "router.example.com",
      ttl: .automatic
    )

    #expect(record.id == nil)
    #expect(record.zoneId == nil)
    #expect(record.zoneName == nil)
    #expect(record.name == "1.168.192.in-addr.arpa")
    #expect(record.type == .ptr)
    #expect(record.content == "router.example.com")
    #expect(record.ttl == .automatic)
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.comment == nil)
  }

  @Test("PTR target domain validation - valid hostnames")
  func testValidPTRTargetDomains() {
    let validTargets = [
      "example.com",
      "host.example.org",
      "server-1.example.net",
      "web123.example.co.uk",
      "a.b.c.d.example.com",
      "host.sub.domain.example.com",
      "web-server.example.com",
      "1host.example.com",
      "host1.example.com",
      "localhost.example.com.",  // FQDN with trailing dot
    ]

    for target in validTargets {
      #expect(PTRRecord.isValidHostname(target) == true, "Target '\(target)' should be valid")

      let record = PTRRecord(
        name: "1.0.0.127.in-addr.arpa",
        content: target,
        ttl: .automatic
      )
      #expect(record.isValidTargetDomain == true, "Record with target '\(target)' should be valid")
    }
  }

  @Test("PTR target domain validation - invalid hostnames")
  func testInvalidPTRTargetDomains() {
    let invalidTargets = [
      "",  // Empty string
      ".example.com",  // Leading dot
      "host..example.com",  // Double dot
      "-host.example.com",  // Leading hyphen
      "host-.example.com",  // Trailing hyphen
      "host.example-.com",  // Trailing hyphen in component
      "host.example.com-",  // Trailing hyphen at end
      "host@example.com",  // Invalid character
      "host example.com",  // Space
      "host.example.com/path",  // Slash
      "host.example.com:80",  // Port number
    ]

    for target in invalidTargets {
      #expect(PTRRecord.isValidHostname(target) == false, "Target '\(target)' should be invalid")

      let record = PTRRecord(
        name: "1.0.0.127.in-addr.arpa",
        content: target,
        ttl: .automatic
      )
      #expect(
        record.isValidTargetDomain == false, "Record with target '\(target)' should be invalid")
    }
  }

  @Test("PTR IPv4 reverse DNS name validation - valid names")
  func testValidIPv4ReverseDNSNames() {
    let validNames = [
      "1.0.0.127.in-addr.arpa",  // Full reverse
      "254.1.168.192.in-addr.arpa",  // Full reverse
      "0.0.0.0.in-addr.arpa",  // Zero address
      "255.255.255.255.in-addr.arpa",  // Broadcast address
      "1.0.0.127.in-addr.arpa.",  // FQDN with trailing dot
    ]

    for name in validNames {
      #expect(
        PTRRecord.isValidReverseDNSName(name) == true, "Reverse DNS name '\(name)' should be valid")

      let record = PTRRecord(
        name: name,
        content: "host.example.com",
        ttl: .automatic
      )
      #expect(
        record.isValidReverseDNSName == true,
        "Record with reverse DNS name '\(name)' should be valid")
      #expect(record.isIPv4Reverse == true, "Record should be identified as IPv4 reverse")
      #expect(record.isIPv6Reverse == false, "Record should not be identified as IPv6 reverse")
    }
  }

  @Test("PTR IPv6 reverse DNS name validation - valid names")
  func testValidIPv6ReverseDNSNames() {
    let validNames = [
      // Full IPv6 reverse
      "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.2.ip6.arpa",
      // Full IPv6 reverse
      "b.a.9.8.7.6.5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa",
      // Partial IPv6 reverse
      "1.0.0.2.ip6.arpa",
      // Partial IPv6 reverse
      "8.b.d.0.1.0.0.2.ip6.arpa",
      // FQDN
      "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.2.ip6.arpa.",
    ]

    for name in validNames {
      #expect(
        PTRRecord.isValidReverseDNSName(name) == true,
        "IPv6 reverse DNS name '\(name)' should be valid")

      let record = PTRRecord(
        name: name,
        content: "host.example.com",
        ttl: .automatic
      )
      #expect(
        record.isValidReverseDNSName == true,
        "Record with IPv6 reverse DNS name '\(name)' should be valid")
      #expect(record.isIPv6Reverse == true, "Record should be identified as IPv6 reverse")
      #expect(record.isIPv4Reverse == false, "Record should not be identified as IPv4 reverse")
    }
  }

  @Test("PTR reverse DNS name validation - invalid names")
  func testInvalidReverseDNSNames() {
    let invalidNames = [
      "",  // Empty string
      "example.com",  // Regular domain
      "256.0.0.127.in-addr.arpa",  // Invalid octet (>255)
      "1.0.0.0.0.in-addr.arpa",  // Too many components
      "a.0.0.127.in-addr.arpa",  // Non-numeric octet
      "1.0.0.127.invalid.arpa",  // Wrong suffix
      // Invalid hex digit
      "g.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.2.ip6.arpa",
      // Wrong IPv6 suffix
      "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.2.invalid.arpa",
      "..in-addr.arpa",  // Double dot
      ".1.0.0.127.in-addr.arpa",  // Leading dot
    ]

    for name in invalidNames {
      #expect(
        PTRRecord.isValidReverseDNSName(name) == false,
        "Reverse DNS name '\(name)' should be invalid")

      let record = PTRRecord(
        name: name,
        content: "host.example.com",
        ttl: .automatic
      )
      #expect(
        record.isValidReverseDNSName == false,
        "Record with reverse DNS name '\(name)' should be invalid")
    }
  }

  @Test("PTR IP address extraction")
  func testPTRIPAddressExtraction() {
    // IPv4 address extraction
    let ipv4Cases = [
      ("1.0.0.127.in-addr.arpa", "127.0.0.1"),
      ("254.1.168.192.in-addr.arpa", "192.168.1.254"),
      ("1.1.1.1.in-addr.arpa", "1.1.1.1"),
      ("8.8.8.8.in-addr.arpa", "8.8.8.8"),
    ]

    for (reverseName, expectedIP) in ipv4Cases {
      let record = PTRRecord(
        name: reverseName,
        content: "host.example.com",
        ttl: .automatic
      )
      #expect(
        record.extractedIPAddress == expectedIP,
        "Should extract IP '\(expectedIP)' from '\(reverseName)'")
    }

    // IPv6 address extraction (full addresses only)
    let ipv6Record = PTRRecord(
      name: "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.2.ip6.arpa",
      content: "host.example.com",
      ttl: .automatic
    )
    #expect(ipv6Record.extractedIPAddress == "2001:0000:0000:0000:0000:0000:0000:0001")

    // Partial reverse DNS should not extract IP
    let partialRecord = PTRRecord(
      name: "1.168.192.in-addr.arpa",
      content: "host.example.com",
      ttl: .automatic
    )
    #expect(partialRecord.extractedIPAddress == nil)
  }

  @Test("PTR FQDN handling")
  func testPTRFQDNHandling() {
    // Test with FQDN (trailing dot)
    let fqdnRecord = PTRRecord(
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com.",
      ttl: .automatic
    )
    #expect(fqdnRecord.isFQDN == true)
    #expect(fqdnRecord.fqdnContent == "localhost.example.com.")
    #expect(fqdnRecord.normalizedContent == "localhost.example.com")

    // Test without FQDN
    let normalRecord = PTRRecord(
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com",
      ttl: .automatic
    )
    #expect(normalRecord.isFQDN == false)
    #expect(normalRecord.fqdnContent == "localhost.example.com.")
    #expect(normalRecord.normalizedContent == "localhost.example.com")
  }

  @Test("PTRRecord JSON serialization")
  func testPTRRecordJSONSerialization() throws {
    let record = PTRRecord(
      id: "372e67954025e0ba6aaa6d586b9e0b59",
      zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
      zoneName: "1.0.0.127.in-addr.arpa",
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com",
      ttl: .seconds(3600),
      locked: false,
      comment: "Localhost reverse DNS",
      tags: ["reverse", "localhost"],
      createdOn: Date(timeIntervalSince1970: 1_609_459_200),
      modifiedOn: Date(timeIntervalSince1970: 1_609_545_600)
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(record)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    #expect(json["id"] as? String == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(json["zone_id"] as? String == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(json["zone_name"] as? String == "1.0.0.127.in-addr.arpa")
    #expect(json["name"] as? String == "1.0.0.127.in-addr.arpa")
    #expect(json["type"] as? String == "PTR")
    #expect(json["content"] as? String == "localhost.example.com")
    #expect(json["ttl"] as? Int == 3600)
    #expect(json["proxiable"] as? Bool == false)
    #expect(json["proxied"] as? Bool == false)
    #expect(json["locked"] as? Bool == false)
    #expect(json["comment"] as? String == "Localhost reverse DNS")

    let tags = json["tags"] as? [String]
    #expect(tags?.count == 2)
    #expect(tags?.contains("reverse") == true)
    #expect(tags?.contains("localhost") == true)
  }

  @Test("PTRRecord JSON deserialization")
  func testPTRRecordJSONDeserialization() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
          "zone_name": "1.168.192.in-addr.arpa",
          "name": "254.1.168.192.in-addr.arpa",
          "type": "PTR",
          "content": "router.example.com",
          "ttl": 3600,
          "proxiable": false,
          "proxied": false,
          "locked": false,
          "comment": "Router reverse DNS",
          "tags": ["network", "router"],
          "created_on": "2021-01-01T00:00:00Z",
          "modified_on": "2021-01-02T00:00:00Z"
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let record = try decoder.decode(PTRRecord.self, from: data)

    #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(record.zoneName == "1.168.192.in-addr.arpa")
    #expect(record.name == "254.1.168.192.in-addr.arpa")
    #expect(record.type == .ptr)
    #expect(record.content == "router.example.com")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.locked == false)
    #expect(record.comment == "Router reverse DNS")
    #expect(record.tags?.count == 2)
    #expect(record.tags?.contains("network") == true)
    #expect(record.tags?.contains("router") == true)
    #expect(record.isValidTargetDomain == true)
    #expect(record.isValidReverseDNSName == true)
    #expect(record.isIPv4Reverse == true)
    #expect(record.extractedIPAddress == "192.168.1.254")
  }

  @Test("PTRRecord hashable conformance")
  func testPTRRecordHashable() {
    let record1 = PTRRecord(
      id: "test-id",
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com",
      ttl: .seconds(3600)
    )

    let record2 = PTRRecord(
      id: "test-id",
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com",
      ttl: .seconds(3600)
    )

    let record3 = PTRRecord(
      id: "different-id",
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.example.com",
      ttl: .seconds(3600)
    )

    #expect(record1 == record2)
    #expect(record1 != record3)
    #expect(record1.hashValue == record2.hashValue)
  }

  @Test("PTRRecord common use cases")
  func testPTRRecordCommonUseCases() {
    // Localhost reverse DNS
    let localhostRecord = PTRRecord(
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost",
      ttl: .seconds(3600)
    )
    #expect(localhostRecord.isValid == true)
    #expect(localhostRecord.extractedIPAddress == "127.0.0.1")

    // Web server reverse DNS
    let webServerRecord = PTRRecord(
      name: "1.2.3.4.in-addr.arpa",
      content: "web.example.com",
      ttl: .seconds(3600)
    )
    #expect(webServerRecord.isValid == true)
    #expect(webServerRecord.extractedIPAddress == "4.3.2.1")

    // Mail server reverse DNS
    let mailServerRecord = PTRRecord(
      name: "10.1.168.192.in-addr.arpa",
      content: "mail.example.com",
      ttl: .seconds(3600)
    )
    #expect(mailServerRecord.isValid == true)
    #expect(mailServerRecord.extractedIPAddress == "192.168.1.10")

    // IPv6 reverse DNS (simplified)
    let ipv6Record = PTRRecord(
      name: "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.2.ip6.arpa",
      content: "ipv6.example.com",
      ttl: .seconds(3600)
    )
    #expect(ipv6Record.isValid == true)
    #expect(ipv6Record.isIPv6Reverse == true)

    // Partial reverse DNS delegation
    let partialRecord = PTRRecord(
      name: "1.168.192.in-addr.arpa",
      content: "ns1.isp.com",
      ttl: .seconds(86400)
    )
    #expect(partialRecord.isValidReverseDNSName == true)
    #expect(partialRecord.isValidTargetDomain == true)
    #expect(partialRecord.extractedIPAddress == nil)  // Partial records don't extract full IPs

    // FQDN target
    let fqdnRecord = PTRRecord(
      name: "1.0.0.127.in-addr.arpa",
      content: "localhost.localdomain.",
      ttl: .seconds(3600)
    )
    #expect(fqdnRecord.isValid == true)
    #expect(fqdnRecord.isFQDN == true)
  }
}

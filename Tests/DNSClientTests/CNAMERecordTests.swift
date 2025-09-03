import Foundation
import Testing

@testable import DNSClient

@Suite("CNAMERecord Tests")
struct CNAMERecordTests {

  @Test("CNAMERecord initialization")
  func testCNAMERecordInitialization() {
    let record = CNAMERecord(
      id: "test-id",
      zoneId: "zone-123",
      zoneName: "example.com",
      name: "www.example.com",
      content: "target.example.com",
      ttl: .seconds(3600),
      proxiable: true,
      proxied: false,
      comment: "Test CNAME record"
    )

    #expect(record.id == "test-id")
    #expect(record.zoneId == "zone-123")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "www.example.com")
    #expect(record.type == .cname)
    #expect(record.content == "target.example.com")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == true)
    #expect(record.proxied == false)
    #expect(record.comment == "Test CNAME record")
  }

  @Test("Domain name validation - valid domains")
  func testValidDomainNames() {
    let validDomains = [
      "example.com",
      "www.example.com",
      "sub.domain.example.com",
      "test-site.example.org",
      "123.example.com",
      "test123.example.com",
      "x.com",
      "example.com.",  // FQDN with trailing dot
      "localhost",
      "test",
      "a1-b2.example.com"
    ]

    for domain in validDomains {
      #expect(
        CNAMERecord.isValidDomainName(domain) == true, "Domain \(domain) should be valid")

      let record = CNAMERecord(name: "alias.com", content: domain, ttl: .automatic)
      #expect(
        record.isValidDomainName == true, "Record with domain \(domain) should be valid")
    }
  }

  @Test("Domain name validation - invalid domains")
  func testInvalidDomainNames() {
    let invalidDomains = [
      "",  // Empty string
      ".",  // Just a dot
      ".example.com",  // Leading dot
      "example..com",  // Double dot
      "-example.com",  // Leading hyphen in label
      "example-.com",  // Trailing hyphen in label
      "ex ample.com",  // Space in domain
      "example.com/path",  // Path included
      "example.c_m",  // Underscore (invalid in hostname)
      "192.168.1.1",  // IP address (not a domain name)
      "2001:db8::1"  // IPv6 address
    ]

    for domain in invalidDomains {
      #expect(
        CNAMERecord.isValidDomainName(domain) == false, "Domain \(domain) should be invalid"
      )

      let record = CNAMERecord(name: "alias.com", content: domain, ttl: .automatic)
      #expect(
        record.isValidDomainName == false, "Record with domain \(domain) should be invalid")
    }
  }

  @Test("CNAMERecord JSON serialization")
  func testCNAMERecordJSONSerialization() throws {
    let record = CNAMERecord(
      id: "372e67954025e0ba6aaa6d586b9e0b59",
      name: "www.example.com",
      content: "target.example.com",
      ttl: .seconds(3600),
      comment: "Test CNAME record"
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(record)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    #expect(json["id"] as? String == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(json["name"] as? String == "www.example.com")
    #expect(json["type"] as? String == "CNAME")
    #expect(json["content"] as? String == "target.example.com")
    #expect(json["ttl"] as? Int == 3600)
    #expect(json["comment"] as? String == "Test CNAME record")
  }

  @Test("CNAMERecord hashable conformance")
  func testCNAMERecordHashable() {
    let record1 = CNAMERecord(
      id: "test-id",
      name: "www.example.com",
      content: "target.example.com",
      ttl: .seconds(3600)
    )

    let record2 = CNAMERecord(
      id: "test-id",
      name: "www.example.com",
      content: "target.example.com",
      ttl: .seconds(3600)
    )

    let record3 = CNAMERecord(
      id: "different-id",
      name: "www.example.com",
      content: "target.example.com",
      ttl: .seconds(3600)
    )

    #expect(record1 == record2)
    #expect(record1 != record3)
    #expect(record1.hashValue == record2.hashValue)
  }
}

import Foundation
import Testing

@testable import DNSClient

@Suite("TXTRecord Tests")
struct TXTRecordTests {

  @Test("TXTRecord initialization")
  func testTXTRecordInitialization() {
    let record = TXTRecord(
      id: "test-id",
      zoneId: "zone-123",
      zoneName: "example.com",
      name: "_dmarc.example.com",
      content: "v=DMARC1; p=reject; rua=mailto:dmarc@example.com",
      ttl: .seconds(3600),
      comment: "DMARC policy record"
    )

    #expect(record.id == "test-id")
    #expect(record.zoneId == "zone-123")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "_dmarc.example.com")
    #expect(record.type == .txt)
    #expect(record.content == "v=DMARC1; p=reject; rua=mailto:dmarc@example.com")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.comment == "DMARC policy record")
  }

  @Test("TXTRecord minimal initialization")
  func testTXTRecordMinimalInitialization() {
    let record = TXTRecord(
      name: "example.com",
      content: "Simple text record",
      ttl: .automatic
    )

    #expect(record.id == nil)
    #expect(record.zoneId == nil)
    #expect(record.zoneName == nil)
    #expect(record.name == "example.com")
    #expect(record.type == .txt)
    #expect(record.content == "Simple text record")
    #expect(record.ttl == .automatic)
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.comment == nil)
  }

  @Test("TXT content validation - valid content")
  func testValidTXTContent() {
    let validContents = [
      "",  // Empty content
      "Simple text",  // Basic text
      "v=spf1 include:_spf.google.com ~all",  // SPF record
      "v=DMARC1; p=reject; rua=mailto:dmarc@example.com",  // DMARC record
      "google-site-verification=abc123",  // Google verification
      "facebook-domain-verification=xyz789",  // Facebook verification
      String(repeating: "a", count: 255),  // Maximum length
      "Text with numbers 123 and symbols !@#$%^&*()",  // Mixed content
      "Multi\nline\ntext",  // Multiline text
      "Text with \"quotes\" and 'apostrophes'",  // Quoted content
      "Text with unicode: 🌟 ñ ü ç"  // Unicode characters
    ]

    for content in validContents {
      let record = TXTRecord(name: "example.com", content: content, ttl: .automatic)
      #expect(record.isValidContent == true, "Content '\(content)' should be valid")
      #expect(TXTRecord.isValidTextContent(content) == true, "Content '\(content)' should be valid")
    }
  }

  @Test("TXT content validation - invalid content")
  func testInvalidTXTContent() {
    let invalidContents = [
      String(repeating: "a", count: 256)  // Too long
    ]

    for content in invalidContents {
      let record = TXTRecord(name: "example.com", content: content, ttl: .automatic)
      #expect(
        record.isValidContent == false, "Content should be invalid (length: \(content.count))")
      #expect(
        TXTRecord.isValidTextContent(content) == false,
        "Content should be invalid (length: \(content.count))")
    }
  }

  @Test("TXT content quoting")
  func testTXTContentQuoting() {
    let testCases = [
      ("simple", "simple"),  // No quoting needed
      ("text with spaces", "\"text with spaces\""),  // Spaces require quoting
      ("text\"with\"quotes", "\"text\\\"with\\\"quotes\""),  // Quotes need escaping
      ("text\\with\\backslashes", "\"text\\\\with\\\\backslashes\""),  // Backslashes need escaping
      ("text\twith\ttabs", "\"text\twith\ttabs\""),  // Tabs require quoting
      ("text\nwith\nnewlines", "\"text\nwith\nnewlines\""),  // Newlines require quoting
      ("\"already quoted\"", "\"already quoted\""),  // Already quoted
      ("", ""),  // Empty string
      ("123", "123"),  // Numbers only
      ("!@#$%^&*()", "!@#$%^&*()")  // Special chars without spaces
    ]

    for (input, expected) in testCases {
      let quoted = TXTRecord.quoteTextContent(input)
      #expect(
        quoted == expected, "Quoting '\(input)' should result in '\(expected)', got '\(quoted)'")
    }
  }

  @Test("TXT content unquoting")
  func testTXTContentUnquoting() {
    let testCases = [
      ("simple", "simple"),  // Not quoted
      ("\"text with spaces\"", "text with spaces"),  // Simple quoted text
      ("\"text\\\"with\\\"quotes\"", "text\"with\"quotes"),  // Escaped quotes
      ("\"text\\\\with\\\\backslashes\"", "text\\with\\backslashes"),  // Escaped backslashes
      ("\"already quoted\"", "already quoted"),  // Quoted text
      ("", ""),  // Empty string
      ("\"\"", ""),  // Empty quoted string
      ("\"single", "\"single"),  // Malformed (missing end quote)
      ("single\"", "single\"")  // Malformed (missing start quote)
    ]

    for (input, expected) in testCases {
      let unquoted = TXTRecord.unquoteTextContent(input)
      #expect(
        unquoted == expected,
        "Unquoting '\(input)' should result in '\(expected)', got '\(unquoted)'")
    }
  }

  @Test("TXT structured record detection")
  func testStructuredRecordDetection() {
    let structuredRecords = [
      ("v=spf1 include:_spf.google.com ~all", true, "SPF"),
      ("v=SPF1 include:mailgun.org ~all", true, "SPF"),
      ("v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC", true, "DKIM"),
      ("v=dkim1; k=rsa; p=abc123", true, "DKIM"),
      ("v=DMARC1; p=reject; rua=mailto:dmarc@example.com", true, "DMARC"),
      ("v=dmarc1; p=none; rua=mailto:reports@example.com", true, "DMARC"),
      ("google-site-verification=abc123def456", true, "Google Site Verification"),
      ("facebook-domain-verification=xyz789abc123", true, "Facebook Domain Verification")
    ]

    for (content, shouldBeStructured, expectedType) in structuredRecords {
      let record = TXTRecord(name: "example.com", content: content, ttl: .automatic)
      #expect(
        record.isStructuredRecord == shouldBeStructured,
        "Content '\(content)' structured detection should be \(shouldBeStructured)")
      #expect(
        record.structuredRecordType == expectedType,
        "Content '\(content)' should be detected as '\(expectedType)'")
    }

    let unstructuredRecords = [
      "Simple text record",
      "Random content without structure",
      "This is not a structured record",
      "spf1 include:example.com",  // Missing v= prefix
      "dkim1 k=rsa p=abc123",  // Missing v= prefix
      "dmarc1 p=reject"  // Missing v= prefix
    ]

    for content in unstructuredRecords {
      let record = TXTRecord(name: "example.com", content: content, ttl: .automatic)
      #expect(
        record.isStructuredRecord == false,
        "Content '\(content)' should not be detected as structured")
      #expect(
        record.structuredRecordType == nil, "Content '\(content)' should not have a structured type"
      )
    }
  }

  @Test("TXTRecord JSON serialization")
  func testTXTRecordJSONSerialization() throws {
    let record = TXTRecord(
      id: "372e67954025e0ba6aaa6d586b9e0b59",
      zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
      zoneName: "example.com",
      name: "_dmarc.example.com",
      content: "v=DMARC1; p=reject; rua=mailto:dmarc@example.com",
      ttl: .seconds(3600),
      locked: false,
      comment: "DMARC policy record",
      tags: ["security", "email"],
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
    #expect(json["name"] as? String == "_dmarc.example.com")
    #expect(json["type"] as? String == "TXT")
    #expect(json["content"] as? String == "v=DMARC1; p=reject; rua=mailto:dmarc@example.com")
    #expect(json["ttl"] as? Int == 3600)
    #expect(json["proxiable"] as? Bool == false)
    #expect(json["proxied"] as? Bool == false)
    #expect(json["locked"] as? Bool == false)
    #expect(json["comment"] as? String == "DMARC policy record")

    let tags = json["tags"] as? [String]
    #expect(tags?.count == 2)
    #expect(tags?.contains("security") == true)
    #expect(tags?.contains("email") == true)
  }

  @Test("TXTRecord JSON deserialization")
  func testTXTRecordJSONDeserialization() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
          "zone_name": "example.com",
          "name": "example.com",
          "type": "TXT",
          "content": "v=spf1 include:_spf.google.com ~all",
          "ttl": 3600,
          "proxiable": false,
          "proxied": false,
          "locked": false,
          "comment": "SPF record",
          "tags": ["security", "spf"],
          "created_on": "2021-01-01T00:00:00Z",
          "modified_on": "2021-01-02T00:00:00Z"
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let record = try decoder.decode(TXTRecord.self, from: data)

    #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
    #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
    #expect(record.zoneName == "example.com")
    #expect(record.name == "example.com")
    #expect(record.type == .txt)
    #expect(record.content == "v=spf1 include:_spf.google.com ~all")
    #expect(record.ttl == .seconds(3600))
    #expect(record.proxiable == false)
    #expect(record.proxied == false)
    #expect(record.locked == false)
    #expect(record.comment == "SPF record")
    #expect(record.tags?.count == 2)
    #expect(record.tags?.contains("security") == true)
    #expect(record.tags?.contains("spf") == true)
    #expect(record.isStructuredRecord == true)
    #expect(record.structuredRecordType == "SPF")
  }

  @Test("TXTRecord JSON deserialization with automatic TTL")
  func testTXTRecordJSONDeserializationAutomaticTTL() throws {
    let jsonString = """
      {
          "id": "372e67954025e0ba6aaa6d586b9e0b59",
          "name": "example.com",
          "type": "TXT",
          "content": "Simple text record",
          "ttl": 1
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()

    let record = try decoder.decode(TXTRecord.self, from: data)

    #expect(record.ttl == .automatic)
    #expect(record.content == "Simple text record")
    #expect(record.isValidContent == true)
    #expect(record.isStructuredRecord == false)
    #expect(record.structuredRecordType == nil)
  }

  @Test("TXTRecord hashable conformance")
  func testTXTRecordHashable() {
    let record1 = TXTRecord(
      id: "test-id",
      name: "example.com",
      content: "test content",
      ttl: .seconds(3600)
    )

    let record2 = TXTRecord(
      id: "test-id",
      name: "example.com",
      content: "test content",
      ttl: .seconds(3600)
    )

    let record3 = TXTRecord(
      id: "different-id",
      name: "example.com",
      content: "test content",
      ttl: .seconds(3600)
    )

    #expect(record1 == record2)
    #expect(record1 != record3)
    #expect(record1.hashValue == record2.hashValue)
  }

  @Test("TXTRecord edge cases")
  func testTXTRecordEdgeCases() {
    // Test with empty content
    let emptyRecord = TXTRecord(
      name: "example.com",
      content: "",
      ttl: .seconds(300)
    )
    #expect(emptyRecord.isValidContent == true)
    #expect(emptyRecord.isStructuredRecord == false)

    // Test with maximum length content
    let maxLengthContent = String(repeating: "a", count: 255)
    let maxRecord = TXTRecord(
      name: "example.com",
      content: maxLengthContent,
      ttl: .automatic
    )
    #expect(maxRecord.isValidContent == true)

    // Test with empty tags
    let emptyTagsRecord = TXTRecord(
      name: "example.com",
      content: "test content",
      ttl: .seconds(1800),
      tags: []
    )
    #expect(emptyTagsRecord.tags?.isEmpty == true)
  }

  @Test("TXTRecord common use cases")
  func testTXTRecordCommonUseCases() {
    // SPF record
    let spfRecord = TXTRecord(
      name: "example.com",
      content: "v=spf1 include:_spf.google.com include:mailgun.org ~all",
      ttl: .seconds(3600)
    )
    #expect(spfRecord.isStructuredRecord == true)
    #expect(spfRecord.structuredRecordType == "SPF")

    // DKIM record
    let dkimRecord = TXTRecord(
      name: "selector1._domainkey.example.com",
      content: "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC...",
      ttl: .seconds(3600)
    )
    #expect(dkimRecord.isStructuredRecord == true)
    #expect(dkimRecord.structuredRecordType == "DKIM")

    // DMARC record
    let dmarcRecord = TXTRecord(
      name: "_dmarc.example.com",
      content:
        "v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@example.com; ruf=mailto:dmarc-failures@example.com; fo=1",
      ttl: .seconds(3600)
    )
    #expect(dmarcRecord.isStructuredRecord == true)
    #expect(dmarcRecord.structuredRecordType == "DMARC")

    // Google site verification
    let googleRecord = TXTRecord(
      name: "example.com",
      content: "google-site-verification=abc123def456ghi789jkl012mno345pqr678stu901vwx234yz",
      ttl: .seconds(300)
    )
    #expect(googleRecord.isStructuredRecord == true)
    #expect(googleRecord.structuredRecordType == "Google Site Verification")

    // Generic text record
    let genericRecord = TXTRecord(
      name: "info.example.com",
      content: "This domain is used for examples in documentation",
      ttl: .seconds(1800)
    )
    #expect(genericRecord.isStructuredRecord == false)
    #expect(genericRecord.structuredRecordType == nil)
  }
}

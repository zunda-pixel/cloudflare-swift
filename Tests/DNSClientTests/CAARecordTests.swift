import Testing
import Foundation
@testable import DNSClient

@Suite("CAARecord Tests")
struct CAARecordTests {
    
    @Test("CAARecord initialization")
    func testCAARecordInitialization() {
        let record = CAARecord(
            id: "test-id",
            zoneId: "zone-123",
            zoneName: "example.com",
            name: "example.com",
            content: "0 issue \"letsencrypt.org\"",
            flags: 0,
            tag: "issue",
            value: "letsencrypt.org",
            ttl: .seconds(3600),
            comment: "Let's Encrypt CAA record"
        )
        
        #expect(record.id == "test-id")
        #expect(record.zoneId == "zone-123")
        #expect(record.zoneName == "example.com")
        #expect(record.name == "example.com")
        #expect(record.type == .caa)
        #expect(record.content == "0 issue \"letsencrypt.org\"")
        #expect(record.flags == 0)
        #expect(record.tag == "issue")
        #expect(record.value == "letsencrypt.org")
        #expect(record.ttl == .seconds(3600))
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.comment == "Let's Encrypt CAA record")
        #expect(record.data?.flags == 0)
        #expect(record.data?.tag == "issue")
        #expect(record.data?.value == "letsencrypt.org")
    }
    
    @Test("CAARecord minimal initialization")
    func testCAARecordMinimalInitialization() {
        let record = CAARecord(
            name: "example.com",
            content: "128 issue \";\"",
            flags: 128,
            tag: "issue",
            value: ";",
            ttl: .automatic
        )
        
        #expect(record.id == nil)
        #expect(record.zoneId == nil)
        #expect(record.zoneName == nil)
        #expect(record.name == "example.com")
        #expect(record.type == .caa)
        #expect(record.content == "128 issue \";\"")
        #expect(record.flags == 128)
        #expect(record.tag == "issue")
        #expect(record.value == ";")
        #expect(record.ttl == .automatic)
        #expect(record.isCritical == true)
        #expect(record.data?.flags == 128)
        #expect(record.data?.tag == "issue")
        #expect(record.data?.value == ";")
    }
    
    @Test("CAA flags validation")
    func testCAAFlagsValidation() {
        let validFlags = [0, 128]
        
        for flags in validFlags {
            let record = CAARecord(
                name: "example.com",
                content: "\(flags) issue \"letsencrypt.org\"",
                flags: flags,
                tag: "issue",
                value: "letsencrypt.org",
                ttl: .automatic
            )
            #expect(record.isValidFlags == true, "Flags \(flags) should be valid")
            #expect(record.data?.isValidFlags == true, "CAAData flags \(flags) should be valid")
        }
        
        let invalidFlags = [-1, 256, 1000]
        
        for flags in invalidFlags {
            let record = CAARecord(
                name: "example.com",
                content: "\(flags) issue \"letsencrypt.org\"",
                flags: flags,
                tag: "issue",
                value: "letsencrypt.org",
                ttl: .automatic
            )
            #expect(record.isValidFlags == false, "Flags \(flags) should be invalid")
            #expect(record.data?.isValidFlags == false, "CAAData flags \(flags) should be invalid")
        }
    }
    
    @Test("CAA tag validation")
    func testCAATagValidation() {
        let validTags = ["issue", "issuewild", "iodef", "ISSUE", "ISSUEWILD", "IODEF"]
        
        for tag in validTags {
            #expect(CAARecord.isValidCAATag(tag) == true, "Tag '\(tag)' should be valid")
            
            let record = CAARecord(
                name: "example.com",
                content: "0 \(tag) \"example.org\"",
                flags: 0,
                tag: tag,
                value: "example.org",
                ttl: .automatic
            )
            #expect(record.isValidTag == true, "Record with tag '\(tag)' should be valid")
        }
        
        let invalidTags = ["", "invalid", "wildcard", "report"]
        
        for tag in invalidTags {
            #expect(CAARecord.isValidCAATag(tag) == false, "Tag '\(tag)' should be invalid")
            
            let record = CAARecord(
                name: "example.com",
                content: "0 \(tag) \"example.org\"",
                flags: 0,
                tag: tag,
                value: "example.org",
                ttl: .automatic
            )
            #expect(record.isValidTag == false, "Record with tag '\(tag)' should be invalid")
        }
    }
    
    @Test("CAA value validation for issue/issuewild tags")
    func testCAAValueValidationForIssue() {
        let validValues = [
            ";",
            "letsencrypt.org",
            "digicert.com",
            "sectigo.com",
            "amazon.com",
            "google.com"
        ]
        
        for tag in ["issue", "issuewild"] {
            for value in validValues {
                #expect(CAARecord.isValidCAAValue(value, for: tag) == true, "Value '\(value)' should be valid for tag '\(tag)'")
                
                let record = CAARecord(
                    name: "example.com",
                    content: "0 \(tag) \"\(value)\"",
                    flags: 0,
                    tag: tag,
                    value: value,
                    ttl: .automatic
                )
                #expect(record.isValidValue == true, "Record with value '\(value)' should be valid for tag '\(tag)'")
            }
        }
        
        let invalidValues = [
            "",
            "invalid..domain",
            ".invalid.domain",
            "invalid.domain.",
            "invalid@domain.com",
            "http://example.com"
        ]
        
        for tag in ["issue", "issuewild"] {
            for value in invalidValues {
                #expect(CAARecord.isValidCAAValue(value, for: tag) == false, "Value '\(value)' should be invalid for tag '\(tag)'")
            }
        }
    }
    
    @Test("CAA value validation for iodef tag")
    func testCAAValueValidationForIODEF() {
        let validValues = [
            "mailto:security@example.com",
            "mailto:admin@example.org",
            "security@example.com",      // Plain email address
            "http://example.com/security",
            "https://example.com/caa-report",
            "https://security.example.com/report"
        ]
        
        for value in validValues {
            #expect(CAARecord.isValidCAAValue(value, for: "iodef") == true, "Value '\(value)' should be valid for iodef tag")
            
            let record = CAARecord(
                name: "example.com",
                content: "0 iodef \"\(value)\"",
                flags: 0,
                tag: "iodef",
                value: value,
                ttl: .automatic
            )
            #expect(record.isValidValue == true, "Record with iodef value '\(value)' should be valid")
        }
        
        let invalidValues = [
            "",
            "ftp://example.com",     // Invalid protocol
            "mailto:",               // Empty email
            "mailto:invalid-email",  // Invalid email format
            "http://",               // Empty URL
            "https://",              // Empty URL
            "invalid-url"            // Not a URL
        ]
        
        for value in invalidValues {
            #expect(CAARecord.isValidCAAValue(value, for: "iodef") == false, "Value '\(value)' should be invalid for iodef tag")
        }
    }
    
    @Test("CAARecord JSON serialization")
    func testCAARecordJSONSerialization() throws {
        let caaData = CAAData(flags: 0, tag: "issue", value: "letsencrypt.org")
        let record = CAARecord(
            id: "372e67954025e0ba6aaa6d586b9e0b59",
            zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
            zoneName: "example.com",
            name: "example.com",
            content: "0 issue \"letsencrypt.org\"",
            flags: 0,
            tag: "issue",
            value: "letsencrypt.org",
            data: caaData,
            ttl: .seconds(3600),
            locked: false,
            comment: "Let's Encrypt CAA record",
            tags: ["security", "ssl"],
            createdOn: Date(timeIntervalSince1970: 1609459200),
            modifiedOn: Date(timeIntervalSince1970: 1609545600)
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(record)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        #expect(json["id"] as? String == "372e67954025e0ba6aaa6d586b9e0b59")
        #expect(json["zone_id"] as? String == "023e105f4ecef8ad9ca31a8372d0c353")
        #expect(json["zone_name"] as? String == "example.com")
        #expect(json["name"] as? String == "example.com")
        #expect(json["type"] as? String == "CAA")
        #expect(json["content"] as? String == "0 issue \"letsencrypt.org\"")
        #expect(json["flags"] as? Int == 0)
        #expect(json["tag"] as? String == "issue")
        #expect(json["value"] as? String == "letsencrypt.org")
        #expect(json["ttl"] as? Int == 3600)
        #expect(json["proxiable"] as? Bool == false)
        #expect(json["proxied"] as? Bool == false)
        #expect(json["locked"] as? Bool == false)
        #expect(json["comment"] as? String == "Let's Encrypt CAA record")
        
        let tags = json["tags"] as? [String]
        #expect(tags?.count == 2)
        #expect(tags?.contains("security") == true)
        #expect(tags?.contains("ssl") == true)
        
        let dataDict = json["data"] as? [String: Any]
        #expect(dataDict?["flags"] as? Int == 0)
        #expect(dataDict?["tag"] as? String == "issue")
        #expect(dataDict?["value"] as? String == "letsencrypt.org")
    }
    
    @Test("CAARecord JSON deserialization")
    func testCAARecordJSONDeserialization() throws {
        let jsonString = """
        {
            "id": "372e67954025e0ba6aaa6d586b9e0b59",
            "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
            "zone_name": "example.com",
            "name": "example.com",
            "type": "CAA",
            "content": "128 issue \\\";\\\"",
            "flags": 128,
            "tag": "issue",
            "value": ";",
            "data": {
                "flags": 128,
                "tag": "issue",
                "value": ";"
            },
            "ttl": 3600,
            "proxiable": false,
            "proxied": false,
            "locked": false,
            "comment": "Disable certificate issuance",
            "tags": ["security"],
            "created_on": "2021-01-01T00:00:00Z",
            "modified_on": "2021-01-02T00:00:00Z"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let record = try decoder.decode(CAARecord.self, from: data)
        
        #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
        #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
        #expect(record.zoneName == "example.com")
        #expect(record.name == "example.com")
        #expect(record.type == .caa)
        #expect(record.content == "128 issue \";\"")
        #expect(record.flags == 128)
        #expect(record.tag == "issue")
        #expect(record.value == ";")
        #expect(record.ttl == .seconds(3600))
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.locked == false)
        #expect(record.comment == "Disable certificate issuance")
        #expect(record.tags?.count == 1)
        #expect(record.tags?.contains("security") == true)
        #expect(record.data?.flags == 128)
        #expect(record.data?.tag == "issue")
        #expect(record.data?.value == ";")
        #expect(record.isCritical == true)
    }
    
    @Test("CAARecord hashable conformance")
    func testCAARecordHashable() {
        let record1 = CAARecord(
            id: "test-id",
            name: "example.com",
            content: "0 issue \"letsencrypt.org\"",
            flags: 0,
            tag: "issue",
            value: "letsencrypt.org",
            ttl: .seconds(3600)
        )
        
        let record2 = CAARecord(
            id: "test-id",
            name: "example.com",
            content: "0 issue \"letsencrypt.org\"",
            flags: 0,
            tag: "issue",
            value: "letsencrypt.org",
            ttl: .seconds(3600)
        )
        
        let record3 = CAARecord(
            id: "different-id",
            name: "example.com",
            content: "0 issue \"letsencrypt.org\"",
            flags: 0,
            tag: "issue",
            value: "letsencrypt.org",
            ttl: .seconds(3600)
        )
        
        #expect(record1 == record2)
        #expect(record1 != record3)
        #expect(record1.hashValue == record2.hashValue)
    }
    
    @Test("CAARecord common use cases")
    func testCAARecordCommonUseCases() {
        // Allow Let's Encrypt
        let letsEncryptRecord = CAARecord(
            name: "example.com",
            content: "0 issue \"letsencrypt.org\"",
            flags: 0,
            tag: "issue",
            value: "letsencrypt.org",
            ttl: .seconds(3600)
        )
        #expect(letsEncryptRecord.isValid == true)
        #expect(letsEncryptRecord.isCritical == false)
        
        // Disable all certificate issuance (critical)
        let disableRecord = CAARecord(
            name: "example.com",
            content: "128 issue \";\"",
            flags: 128,
            tag: "issue",
            value: ";",
            ttl: .seconds(3600)
        )
        #expect(disableRecord.isValid == true)
        #expect(disableRecord.isCritical == true)
        
        // Allow wildcard certificates from DigiCert
        let wildcardRecord = CAARecord(
            name: "example.com",
            content: "0 issuewild \"digicert.com\"",
            flags: 0,
            tag: "issuewild",
            value: "digicert.com",
            ttl: .seconds(3600)
        )
        #expect(wildcardRecord.isValid == true)
        
        // IODEF reporting with email
        let iodefEmailRecord = CAARecord(
            name: "example.com",
            content: "0 iodef \"mailto:security@example.com\"",
            flags: 0,
            tag: "iodef",
            value: "mailto:security@example.com",
            ttl: .seconds(3600)
        )
        #expect(iodefEmailRecord.isValid == true)
        
        // IODEF reporting with HTTPS URL
        let iodefURLRecord = CAARecord(
            name: "example.com",
            content: "0 iodef \"https://example.com/caa-report\"",
            flags: 0,
            tag: "iodef",
            value: "https://example.com/caa-report",
            ttl: .seconds(3600)
        )
        #expect(iodefURLRecord.isValid == true)
    }
}
import Testing
import Foundation
@testable import DNSClient

@Suite("NSRecord Tests")
struct NSRecordTests {
    
    @Test("NSRecord initialization")
    func testNSRecordInitialization() {
        let record = NSRecord(
            id: "test-id",
            zoneId: "zone-123",
            zoneName: "example.com",
            name: "subdomain.example.com",
            content: "ns1.example.com",
            ttl: .seconds(3600),
            comment: "Name server record"
        )
        
        #expect(record.id == "test-id")
        #expect(record.zoneId == "zone-123")
        #expect(record.zoneName == "example.com")
        #expect(record.name == "subdomain.example.com")
        #expect(record.type == .ns)
        #expect(record.content == "ns1.example.com")
        #expect(record.ttl == .seconds(3600))
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.comment == "Name server record")
    }
    
    @Test("NSRecord minimal initialization")
    func testNSRecordMinimalInitialization() {
        let record = NSRecord(
            name: "example.com",
            content: "ns2.example.com",
            ttl: .automatic
        )
        
        #expect(record.id == nil)
        #expect(record.zoneId == nil)
        #expect(record.zoneName == nil)
        #expect(record.name == "example.com")
        #expect(record.type == .ns)
        #expect(record.content == "ns2.example.com")
        #expect(record.ttl == .automatic)
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.comment == nil)
    }
    
    @Test("NS name server validation - valid hostnames")
    func testValidNSNameServers() {
        let validNameServers = [
            "ns1.example.com",
            "ns2.example.org",
            "nameserver.example.net",
            "dns1.example.co.uk",
            "a.b.c.d.example.com",
            "ns.sub.domain.example.com",
            "ns-server.example.com",
            "1ns.example.com",
            "ns1.example.com.",          // FQDN with trailing dot
            "cloudflare.com"
        ]
        
        for nameServer in validNameServers {
            #expect(NSRecord.isValidHostname(nameServer) == true, "Name server '\(nameServer)' should be valid")
            
            let record = NSRecord(
                name: "example.com",
                content: nameServer,
                ttl: .automatic
            )
            #expect(record.isValidNameServer == true, "Record with name server '\(nameServer)' should be valid")
        }
    }
    
    @Test("NS name server validation - invalid hostnames")
    func testInvalidNSNameServers() {
        let invalidNameServers = [
            "",                         // Empty string
            ".example.com",             // Leading dot
            "ns..example.com",          // Double dot
            "-ns.example.com",          // Leading hyphen
            "ns-.example.com",          // Trailing hyphen
            "ns.example-.com",          // Trailing hyphen in component
            "ns.example.com-",          // Trailing hyphen at end
            "ns@example.com",           // Invalid character
            "ns example.com",           // Space
            "ns.example.com/path",      // Slash
            "ns.example.com:53"         // Port number
        ]
        
        for nameServer in invalidNameServers {
            #expect(NSRecord.isValidHostname(nameServer) == false, "Name server '\(nameServer)' should be invalid")
            
            let record = NSRecord(
                name: "example.com",
                content: nameServer,
                ttl: .automatic
            )
            #expect(record.isValidNameServer == false, "Record with name server '\(nameServer)' should be invalid")
        }
    }
    
    @Test("NS FQDN handling")
    func testNSFQDNHandling() {
        // Test with FQDN (trailing dot)
        let fqdnRecord = NSRecord(
            name: "example.com",
            content: "ns1.example.com.",
            ttl: .automatic
        )
        #expect(fqdnRecord.isFQDN == true)
        #expect(fqdnRecord.fqdnContent == "ns1.example.com.")
        #expect(fqdnRecord.normalizedContent == "ns1.example.com")
        
        // Test without FQDN
        let normalRecord = NSRecord(
            name: "example.com",
            content: "ns1.example.com",
            ttl: .automatic
        )
        #expect(normalRecord.isFQDN == false)
        #expect(normalRecord.fqdnContent == "ns1.example.com.")
        #expect(normalRecord.normalizedContent == "ns1.example.com")
    }
    
    @Test("NSRecord JSON serialization")
    func testNSRecordJSONSerialization() throws {
        let record = NSRecord(
            id: "372e67954025e0ba6aaa6d586b9e0b59",
            zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
            zoneName: "example.com",
            name: "subdomain.example.com",
            content: "ns1.example.com",
            ttl: .seconds(3600),
            locked: false,
            comment: "Subdomain name server",
            tags: ["dns", "nameserver"],
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
        #expect(json["name"] as? String == "subdomain.example.com")
        #expect(json["type"] as? String == "NS")
        #expect(json["content"] as? String == "ns1.example.com")
        #expect(json["ttl"] as? Int == 3600)
        #expect(json["proxiable"] as? Bool == false)
        #expect(json["proxied"] as? Bool == false)
        #expect(json["locked"] as? Bool == false)
        #expect(json["comment"] as? String == "Subdomain name server")
        
        let tags = json["tags"] as? [String]
        #expect(tags?.count == 2)
        #expect(tags?.contains("dns") == true)
        #expect(tags?.contains("nameserver") == true)
    }
    
    @Test("NSRecord JSON deserialization")
    func testNSRecordJSONDeserialization() throws {
        let jsonString = """
        {
            "id": "372e67954025e0ba6aaa6d586b9e0b59",
            "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
            "zone_name": "example.com",
            "name": "example.com",
            "type": "NS",
            "content": "ns2.cloudflare.com",
            "ttl": 86400,
            "proxiable": false,
            "proxied": false,
            "locked": false,
            "comment": "Cloudflare name server",
            "tags": ["cloudflare", "dns"],
            "created_on": "2021-01-01T00:00:00Z",
            "modified_on": "2021-01-02T00:00:00Z"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let record = try decoder.decode(NSRecord.self, from: data)
        
        #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
        #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
        #expect(record.zoneName == "example.com")
        #expect(record.name == "example.com")
        #expect(record.type == .ns)
        #expect(record.content == "ns2.cloudflare.com")
        #expect(record.ttl == .seconds(86400))
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.locked == false)
        #expect(record.comment == "Cloudflare name server")
        #expect(record.tags?.count == 2)
        #expect(record.tags?.contains("cloudflare") == true)
        #expect(record.tags?.contains("dns") == true)
        #expect(record.isValidNameServer == true)
    }
    
    @Test("NSRecord hashable conformance")
    func testNSRecordHashable() {
        let record1 = NSRecord(
            id: "test-id",
            name: "example.com",
            content: "ns1.example.com",
            ttl: .seconds(3600)
        )
        
        let record2 = NSRecord(
            id: "test-id",
            name: "example.com",
            content: "ns1.example.com",
            ttl: .seconds(3600)
        )
        
        let record3 = NSRecord(
            id: "different-id",
            name: "example.com",
            content: "ns1.example.com",
            ttl: .seconds(3600)
        )
        
        #expect(record1 == record2)
        #expect(record1 != record3)
        #expect(record1.hashValue == record2.hashValue)
    }
    
    @Test("NSRecord common use cases")
    func testNSRecordCommonUseCases() {
        // Root domain NS records
        let rootNS1 = NSRecord(
            name: "example.com",
            content: "ns1.cloudflare.com",
            ttl: .seconds(86400)
        )
        #expect(rootNS1.isValidNameServer == true)
        
        let rootNS2 = NSRecord(
            name: "example.com",
            content: "ns2.cloudflare.com",
            ttl: .seconds(86400)
        )
        #expect(rootNS2.isValidNameServer == true)
        
        // Subdomain delegation
        let subdomainNS = NSRecord(
            name: "subdomain.example.com",
            content: "ns1.subdomain-provider.com",
            ttl: .seconds(3600)
        )
        #expect(subdomainNS.isValidNameServer == true)
        
        // FQDN name server
        let fqdnNS = NSRecord(
            name: "example.com",
            content: "ns1.example.com.",
            ttl: .seconds(3600)
        )
        #expect(fqdnNS.isValidNameServer == true)
        #expect(fqdnNS.isFQDN == true)
        
        // Common DNS providers
        let commonProviders = [
            "ns1.cloudflare.com",
            "ns2.cloudflare.com",
            "dns1.registrar-servers.com",
            "dns2.registrar-servers.com",
            "ns-1.awsdns-00.com",
            "ns-2.awsdns-01.net"
        ]
        
        for provider in commonProviders {
            let record = NSRecord(
                name: "example.com",
                content: provider,
                ttl: .seconds(86400)
            )
            #expect(record.isValidNameServer == true, "Provider '\(provider)' should be valid")
        }
    }
}
import Testing
import Foundation
@testable import DNSClient

@Suite("SRVRecord Tests")
struct SRVRecordTests {
    
    @Test("SRVRecord initialization")
    func testSRVRecordInitialization() {
        let record = SRVRecord(
            id: "test-id",
            zoneId: "zone-123",
            zoneName: "example.com",
            name: "_sip._tcp.example.com",
            content: "sip.example.com",
            priority: 10,
            weight: 20,
            port: 5060,
            ttl: .seconds(3600),
            comment: "SIP service record"
        )
        
        #expect(record.id == "test-id")
        #expect(record.zoneId == "zone-123")
        #expect(record.zoneName == "example.com")
        #expect(record.name == "_sip._tcp.example.com")
        #expect(record.type == .srv)
        #expect(record.content == "sip.example.com")
        #expect(record.priority == 10)
        #expect(record.weight == 20)
        #expect(record.port == 5060)
        #expect(record.ttl == .seconds(3600))
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.comment == "SIP service record")
        #expect(record.data?.priority == 10)
        #expect(record.data?.weight == 20)
        #expect(record.data?.port == 5060)
        #expect(record.data?.target == "sip.example.com")
    }
    
    @Test("SRVRecord minimal initialization")
    func testSRVRecordMinimalInitialization() {
        let record = SRVRecord(
            name: "_http._tcp.example.com",
            content: "web.example.com",
            priority: 0,
            weight: 5,
            port: 80,
            ttl: .automatic
        )
        
        #expect(record.id == nil)
        #expect(record.zoneId == nil)
        #expect(record.zoneName == nil)
        #expect(record.name == "_http._tcp.example.com")
        #expect(record.type == .srv)
        #expect(record.content == "web.example.com")
        #expect(record.priority == 0)
        #expect(record.weight == 5)
        #expect(record.port == 80)
        #expect(record.ttl == .automatic)
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.comment == nil)
        #expect(record.data?.priority == 0)
        #expect(record.data?.weight == 5)
        #expect(record.data?.port == 80)
        #expect(record.data?.target == "web.example.com")
    }
    
    @Test("SRV priority validation - valid priorities")
    func testValidSRVPriorities() {
        let validPriorities = [0, 1, 10, 100, 1000, 32767, 65535]
        
        for priority in validPriorities {
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: "sip.example.com",
                priority: priority,
                weight: 10,
                port: 5060,
                ttl: .automatic
            )
            #expect(record.isValidPriority == true, "Priority \(priority) should be valid")
            #expect(record.data?.isValidPriority == true, "SRVData priority \(priority) should be valid")
        }
    }
    
    @Test("SRV priority validation - invalid priorities")
    func testInvalidSRVPriorities() {
        let invalidPriorities = [-1, -10, 65536, 100000]
        
        for priority in invalidPriorities {
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: "sip.example.com",
                priority: priority,
                weight: 10,
                port: 5060,
                ttl: .automatic
            )
            #expect(record.isValidPriority == false, "Priority \(priority) should be invalid")
            #expect(record.data?.isValidPriority == false, "SRVData priority \(priority) should be invalid")
        }
    }
    
    @Test("SRV weight validation - valid weights")
    func testValidSRVWeights() {
        let validWeights = [0, 1, 10, 100, 1000, 32767, 65535]
        
        for weight in validWeights {
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: "sip.example.com",
                priority: 10,
                weight: weight,
                port: 5060,
                ttl: .automatic
            )
            #expect(record.isValidWeight == true, "Weight \(weight) should be valid")
            #expect(record.data?.isValidWeight == true, "SRVData weight \(weight) should be valid")
        }
    }
    
    @Test("SRV weight validation - invalid weights")
    func testInvalidSRVWeights() {
        let invalidWeights = [-1, -10, 65536, 100000]
        
        for weight in invalidWeights {
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: "sip.example.com",
                priority: 10,
                weight: weight,
                port: 5060,
                ttl: .automatic
            )
            #expect(record.isValidWeight == false, "Weight \(weight) should be invalid")
            #expect(record.data?.isValidWeight == false, "SRVData weight \(weight) should be invalid")
        }
    }
    
    @Test("SRV port validation - valid ports")
    func testValidSRVPorts() {
        let validPorts = [1, 22, 80, 443, 5060, 8080, 65535]
        
        for port in validPorts {
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: "sip.example.com",
                priority: 10,
                weight: 10,
                port: port,
                ttl: .automatic
            )
            #expect(record.isValidPort == true, "Port \(port) should be valid")
            #expect(record.data?.isValidPort == true, "SRVData port \(port) should be valid")
        }
    }
    
    @Test("SRV port validation - invalid ports")
    func testInvalidSRVPorts() {
        let invalidPorts = [0, -1, -10, 65536, 100000]
        
        for port in invalidPorts {
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: "sip.example.com",
                priority: 10,
                weight: 10,
                port: port,
                ttl: .automatic
            )
            #expect(record.isValidPort == false, "Port \(port) should be invalid")
            #expect(record.data?.isValidPort == false, "SRVData port \(port) should be invalid")
        }
    }
    
    @Test("SRV service name validation - valid names")
    func testValidSRVServiceNames() {
        let validServiceNames = [
            "_sip._tcp.example.com",
            "_http._tcp.example.com",
            "_https._tcp.example.com",
            "_ftp._tcp.example.com",
            "_ssh._tcp.example.com",
            "_smtp._tcp.mail.example.com",
            "_imap._tcp.mail.example.com",
            "_pop3._tcp.mail.example.com",
            "_ldap._tcp.directory.example.com",
            "_xmpp-server._tcp.example.com",
            "_minecraft._tcp.games.example.com"
        ]
        
        for serviceName in validServiceNames {
            #expect(SRVRecord.isValidServiceName(serviceName) == true, "Service name '\(serviceName)' should be valid")
            
            let record = SRVRecord(
                name: serviceName,
                content: "target.example.com",
                priority: 10,
                weight: 10,
                port: 80,
                ttl: .automatic
            )
            #expect(record.isValidServiceName == true, "Record with service name '\(serviceName)' should be valid")
        }
    }
    
    @Test("SRV service name validation - invalid names")
    func testInvalidSRVServiceNames() {
        let invalidServiceNames = [
            "sip.tcp.example.com",          // Missing underscores
            "_sip.tcp.example.com",         // Missing underscore for protocol
            "sip._tcp.example.com",         // Missing underscore for service
            "_._tcp.example.com",           // Empty service name
            "_sip._.example.com",           // Empty protocol name
            "_sip._tcp",                    // Missing domain
            "_sip",                         // Missing protocol and domain
            "",                             // Empty string
            "example.com",                  // Regular domain name
            "_sip._tcp.",                   // Missing domain after dot
            "_sip@tcp.example.com",         // Invalid character
            "_sip._tcp.example..com",       // Double dot in domain
            "_sip._tcp..example.com"        // Double dot after protocol
        ]
        
        for serviceName in invalidServiceNames {
            #expect(SRVRecord.isValidServiceName(serviceName) == false, "Service name '\(serviceName)' should be invalid")
            
            let record = SRVRecord(
                name: serviceName,
                content: "target.example.com",
                priority: 10,
                weight: 10,
                port: 80,
                ttl: .automatic
            )
            #expect(record.isValidServiceName == false, "Record with service name '\(serviceName)' should be invalid")
        }
    }
    
    @Test("SRV target hostname validation - valid hostnames")
    func testValidSRVTargetHostnames() {
        let validHostnames = [
            "target.example.com",
            "sip1.example.org",
            "backup-sip.example.net",
            "sip123.example.co.uk",
            "a.b.c.d.example.com",
            "sip.sub.domain.example.com",
            "sip-server.example.com",
            "1sip.example.com",
            "sip1.example.com",
            "."                             // Root domain (valid for SRV)
        ]
        
        for hostname in validHostnames {
            #expect(SRVRecord.isValidHostname(hostname) == true, "Hostname '\(hostname)' should be valid")
            
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: hostname,
                priority: 10,
                weight: 10,
                port: 5060,
                ttl: .automatic
            )
            #expect(record.isValidTarget == true, "Record with hostname '\(hostname)' should be valid")
            #expect(record.data?.isValidTarget == true, "SRVData with target '\(hostname)' should be valid")
        }
    }
    
    @Test("SRV target hostname validation - invalid hostnames")
    func testInvalidSRVTargetHostnames() {
        let invalidHostnames = [
            "",                             // Empty string
            ".example.com",                 // Leading dot
            "sip..example.com",             // Double dot
            "-sip.example.com",             // Leading hyphen
            "sip-.example.com",             // Trailing hyphen
            "sip.example-.com",             // Trailing hyphen in component
            "sip.example.com-",             // Trailing hyphen at end
            "sip@example.com",              // Invalid character
            "sip example.com",              // Space
            "sip.example.com/path",         // Slash
            "sip.example.com:5060"          // Port number
        ]
        
        for hostname in invalidHostnames {
            #expect(SRVRecord.isValidHostname(hostname) == false, "Hostname '\(hostname)' should be invalid")
            
            let record = SRVRecord(
                name: "_sip._tcp.example.com",
                content: hostname,
                priority: 10,
                weight: 10,
                port: 5060,
                ttl: .automatic
            )
            #expect(record.isValidTarget == false, "Record with hostname '\(hostname)' should be invalid")
        }
    }
    
    @Test("SRV service name parsing")
    func testSRVServiceNameParsing() {
        let testCases = [
            ("_sip._tcp.example.com", "sip", "tcp", "example.com"),
            ("_http._tcp.web.example.com", "http", "tcp", "web.example.com"),
            ("_xmpp-server._tcp.chat.example.org", "xmpp-server", "tcp", "chat.example.org"),
            ("_minecraft._tcp.games.example.net", "minecraft", "tcp", "games.example.net")
        ]
        
        for (fullName, expectedService, expectedProtocol, expectedDomain) in testCases {
            let record = SRVRecord(
                name: fullName,
                content: "target.example.com",
                priority: 10,
                weight: 10,
                port: 80,
                ttl: .automatic
            )
            
            #expect(record.serviceName == expectedService, "Service name should be '\(expectedService)'")
            #expect(record.protocolName == expectedProtocol, "Protocol name should be '\(expectedProtocol)'")
            #expect(record.domainName == expectedDomain, "Domain name should be '\(expectedDomain)'")
        }
    }
    
    @Test("SRVRecord JSON serialization")
    func testSRVRecordJSONSerialization() throws {
        let srvData = SRVData(priority: 10, weight: 20, port: 5060, target: "sip.example.com")
        let record = SRVRecord(
            id: "372e67954025e0ba6aaa6d586b9e0b59",
            zoneId: "023e105f4ecef8ad9ca31a8372d0c353",
            zoneName: "example.com",
            name: "_sip._tcp.example.com",
            content: "sip.example.com",
            priority: 10,
            weight: 20,
            port: 5060,
            data: srvData,
            ttl: .seconds(3600),
            locked: false,
            comment: "SIP service record",
            tags: ["voip", "sip"],
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
        #expect(json["name"] as? String == "_sip._tcp.example.com")
        #expect(json["type"] as? String == "SRV")
        #expect(json["content"] as? String == "sip.example.com")
        #expect(json["priority"] as? Int == 10)
        #expect(json["weight"] as? Int == 20)
        #expect(json["port"] as? Int == 5060)
        #expect(json["ttl"] as? Int == 3600)
        #expect(json["proxiable"] as? Bool == false)
        #expect(json["proxied"] as? Bool == false)
        #expect(json["locked"] as? Bool == false)
        #expect(json["comment"] as? String == "SIP service record")
        
        let tags = json["tags"] as? [String]
        #expect(tags?.count == 2)
        #expect(tags?.contains("voip") == true)
        #expect(tags?.contains("sip") == true)
        
        let dataDict = json["data"] as? [String: Any]
        #expect(dataDict?["priority"] as? Int == 10)
        #expect(dataDict?["weight"] as? Int == 20)
        #expect(dataDict?["port"] as? Int == 5060)
        #expect(dataDict?["target"] as? String == "sip.example.com")
    }
    
    @Test("SRVRecord JSON deserialization")
    func testSRVRecordJSONDeserialization() throws {
        let jsonString = """
        {
            "id": "372e67954025e0ba6aaa6d586b9e0b59",
            "zone_id": "023e105f4ecef8ad9ca31a8372d0c353",
            "zone_name": "example.com",
            "name": "_http._tcp.example.com",
            "type": "SRV",
            "content": "web.example.com",
            "priority": 0,
            "weight": 5,
            "port": 80,
            "data": {
                "priority": 0,
                "weight": 5,
                "port": 80,
                "target": "web.example.com"
            },
            "ttl": 3600,
            "proxiable": false,
            "proxied": false,
            "locked": false,
            "comment": "HTTP service record",
            "tags": ["web", "http"],
            "created_on": "2021-01-01T00:00:00Z",
            "modified_on": "2021-01-02T00:00:00Z"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let record = try decoder.decode(SRVRecord.self, from: data)
        
        #expect(record.id == "372e67954025e0ba6aaa6d586b9e0b59")
        #expect(record.zoneId == "023e105f4ecef8ad9ca31a8372d0c353")
        #expect(record.zoneName == "example.com")
        #expect(record.name == "_http._tcp.example.com")
        #expect(record.type == .srv)
        #expect(record.content == "web.example.com")
        #expect(record.priority == 0)
        #expect(record.weight == 5)
        #expect(record.port == 80)
        #expect(record.ttl == .seconds(3600))
        #expect(record.proxiable == false)
        #expect(record.proxied == false)
        #expect(record.locked == false)
        #expect(record.comment == "HTTP service record")
        #expect(record.tags?.count == 2)
        #expect(record.tags?.contains("web") == true)
        #expect(record.tags?.contains("http") == true)
        #expect(record.data?.priority == 0)
        #expect(record.data?.weight == 5)
        #expect(record.data?.port == 80)
        #expect(record.data?.target == "web.example.com")
        #expect(record.serviceName == "http")
        #expect(record.protocolName == "tcp")
        #expect(record.domainName == "example.com")
    }
    
    @Test("SRVRecord hashable conformance")
    func testSRVRecordHashable() {
        let record1 = SRVRecord(
            id: "test-id",
            name: "_sip._tcp.example.com",
            content: "sip.example.com",
            priority: 10,
            weight: 20,
            port: 5060,
            ttl: .seconds(3600)
        )
        
        let record2 = SRVRecord(
            id: "test-id",
            name: "_sip._tcp.example.com",
            content: "sip.example.com",
            priority: 10,
            weight: 20,
            port: 5060,
            ttl: .seconds(3600)
        )
        
        let record3 = SRVRecord(
            id: "different-id",
            name: "_sip._tcp.example.com",
            content: "sip.example.com",
            priority: 10,
            weight: 20,
            port: 5060,
            ttl: .seconds(3600)
        )
        
        #expect(record1 == record2)
        #expect(record1 != record3)
        #expect(record1.hashValue == record2.hashValue)
    }
    
    @Test("SRVRecord edge cases and common services")
    func testSRVRecordEdgeCasesAndCommonServices() {
        // Test with minimum values
        let minRecord = SRVRecord(
            name: "_test._tcp.example.com",
            content: "target.example.com",
            priority: 0,
            weight: 0,
            port: 1,
            ttl: .automatic
        )
        #expect(minRecord.isValid == true)
        
        // Test with maximum values
        let maxRecord = SRVRecord(
            name: "_test._tcp.example.com",
            content: "target.example.com",
            priority: 65535,
            weight: 65535,
            port: 65535,
            ttl: .seconds(86400)
        )
        #expect(maxRecord.isValid == true)
        
        // Test common services
        let commonServices = [
            ("_http._tcp.example.com", 80),
            ("_https._tcp.example.com", 443),
            ("_ftp._tcp.example.com", 21),
            ("_ssh._tcp.example.com", 22),
            ("_smtp._tcp.example.com", 25),
            ("_pop3._tcp.example.com", 110),
            ("_imap._tcp.example.com", 143),
            ("_sip._tcp.example.com", 5060),
            ("_sips._tcp.example.com", 5061)
        ]
        
        for (serviceName, defaultPort) in commonServices {
            let record = SRVRecord(
                name: serviceName,
                content: "service.example.com",
                priority: 10,
                weight: 10,
                port: defaultPort,
                ttl: .seconds(3600)
            )
            #expect(record.isValid == true, "Service '\(serviceName)' should be valid")
        }
        
        // Test with root domain target
        let rootTargetRecord = SRVRecord(
            name: "_test._tcp.example.com",
            content: ".",
            priority: 0,
            weight: 0,
            port: 1,
            ttl: .automatic
        )
        #expect(rootTargetRecord.isValidTarget == true)
        #expect(rootTargetRecord.isValid == true)
    }
}
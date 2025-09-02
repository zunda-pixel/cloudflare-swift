import Testing
import Foundation
@testable import DNSClient

@Suite("TTL Tests")
struct TTLTests {
    
    @Test("TTL automatic case")
    func testTTLAutomatic() {
        let ttl = TTL.automatic
        #expect(ttl.value == 1)
        #expect(ttl.isValid == true)
    }
    
    @Test("TTL seconds case with valid values")
    func testTTLValidSeconds() {
        let validValues = [60, 300, 3600, 86400]
        
        for value in validValues {
            let ttl = TTL.seconds(value)
            #expect(ttl.value == value)
            #expect(ttl.isValid == true)
        }
    }
    
    @Test("TTL seconds case with invalid values")
    func testTTLInvalidSeconds() {
        let invalidValues = [59, 0, -1, 86401, 100000]
        
        for value in invalidValues {
            let ttl = TTL.seconds(value)
            #expect(ttl.value == value)
            #expect(ttl.isValid == false)
        }
    }
    
    @Test("TTL boundary values")
    func testTTLBoundaryValues() {
        // Test minimum valid value
        let minTTL = TTL.seconds(60)
        #expect(minTTL.isValid == true)
        
        // Test maximum valid value
        let maxTTL = TTL.seconds(86400)
        #expect(maxTTL.isValid == true)
        
        // Test just below minimum
        let belowMinTTL = TTL.seconds(59)
        #expect(belowMinTTL.isValid == false)
        
        // Test just above maximum
        let aboveMaxTTL = TTL.seconds(86401)
        #expect(aboveMaxTTL.isValid == false)
    }
    
    @Test("TTL JSON encoding")
    func testTTLJSONEncoding() throws {
        let encoder = JSONEncoder()
        
        // Test automatic TTL encoding
        let automaticTTL = TTL.automatic
        let automaticData = try encoder.encode(automaticTTL)
        let automaticString = String(data: automaticData, encoding: .utf8)
        #expect(automaticString == "1")
        
        // Test seconds TTL encoding
        let secondsTTL = TTL.seconds(3600)
        let secondsData = try encoder.encode(secondsTTL)
        let secondsString = String(data: secondsData, encoding: .utf8)
        #expect(secondsString == "3600")
    }
    
    @Test("TTL JSON decoding")
    func testTTLJSONDecoding() throws {
        let decoder = JSONDecoder()
        
        // Test automatic TTL decoding
        let automaticData = "1".data(using: .utf8)!
        let automaticTTL = try decoder.decode(TTL.self, from: automaticData)
        #expect(automaticTTL == TTL.automatic)
        
        // Test seconds TTL decoding
        let secondsData = "3600".data(using: .utf8)!
        let secondsTTL = try decoder.decode(TTL.self, from: secondsData)
        #expect(secondsTTL == TTL.seconds(3600))
    }
    
    @Test("TTL hashable conformance")
    func testTTLHashable() {
        let ttl1 = TTL.automatic
        let ttl2 = TTL.automatic
        let ttl3 = TTL.seconds(3600)
        let ttl4 = TTL.seconds(3600)
        let ttl5 = TTL.seconds(7200)
        
        #expect(ttl1 == ttl2)
        #expect(ttl3 == ttl4)
        #expect(ttl1 != ttl3)
        #expect(ttl3 != ttl5)
        
        // Test that equal TTLs have equal hash values
        #expect(ttl1.hashValue == ttl2.hashValue)
        #expect(ttl3.hashValue == ttl4.hashValue)
    }
    
    @Test("TTL validation edge cases")
    func testTTLValidationEdgeCases() {
        // Test common valid values
        let commonValues = [300, 600, 1800, 3600, 7200, 14400, 28800, 43200]
        
        for value in commonValues {
            let ttl = TTL.seconds(value)
            #expect(ttl.isValid == true, "TTL \(value) should be valid")
        }
        
        // Test automatic is always valid
        #expect(TTL.automatic.isValid == true)
    }
}
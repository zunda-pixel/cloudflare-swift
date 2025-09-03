import Foundation
import HTTPClient
import Testing

@testable import DNSClient

@Suite("Batch Operations Tests")
struct BatchOperationsTests {

    // MARK: - Batch Operation Model Tests

    @Test("BatchDNSOperation initialization")
    func testBatchDNSOperationInitialization() throws {
        // Test successful initialization
        let records = [
            ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300)),
            ARecord(name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300)),
        ]

        let operation = try BatchDNSOperation(records: records)
        #expect(operation.records.count == 2)
        #expect(operation.records[0].name == "test1.example.com")
        #expect(operation.records[1].name == "test2.example.com")
    }

    @Test("BatchDNSOperation empty records")
    func testBatchDNSOperationEmptyRecords() {
        // Test empty records array
        #expect(throws: DNSRequestError.emptyBatch) {
            try BatchDNSOperation<ARecord>(records: [])
        }
    }

    @Test("BatchDNSOperation size limit")
    func testBatchDNSOperationSizeLimit() {
        // Test batch size limit
        let records = (1...101).map { index in
            ARecord(
                name: "test\(index).example.com", content: "192.168.1.\(index % 255)",
                ttl: .seconds(300))
        }

        do {
            _ = try BatchDNSOperation(records: records)
            Issue.record("Expected batchSizeExceeded error")
        } catch let error as DNSRequestError {
            if case .batchSizeExceeded(let count, let maximum) = error {
                #expect(count == 101)
                #expect(maximum == 100)
            } else {
                Issue.record("Expected batchSizeExceeded error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("BatchDNSOperation validation")
    func testBatchDNSOperationValidation() throws {
        // Test validation with valid records
        let validRecords = [
            ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300)),
            ARecord(name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300)),
        ]

        let operation = try BatchDNSOperation(records: validRecords)
        try operation.validate()  // Should not throw
    }

    @Test("BatchDNSOperation validation invalid TTL")
    func testBatchDNSOperationValidationInvalidTTL() throws {
        // Test validation with invalid TTL
        let invalidRecords = [
            ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(30)),  // Invalid TTL
            ARecord(name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300)),
        ]

        let operation = try BatchDNSOperation(records: invalidRecords)

        do {
            try operation.validate()
            Issue.record("Expected batchValidationFailed error")
        } catch let error as DNSRequestError {
            if case .batchValidationFailed(let index, let errorContent) = error {
                #expect(index == 0)
                #expect(errorContent.code == 1004)
            } else {
                Issue.record("Expected batchValidationFailed error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("BatchDNSOperation validation empty name")
    func testBatchDNSOperationValidationEmptyName() throws {
        // Test validation with empty name
        let invalidRecords = [
            ARecord(name: "", content: "192.168.1.1", ttl: .seconds(300)),  // Empty name
            ARecord(name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300)),
        ]

        let operation = try BatchDNSOperation(records: invalidRecords)

        do {
            try operation.validate()
            Issue.record("Expected batchValidationFailed error")
        } catch let error as DNSRequestError {
            if case .batchValidationFailed(let index, let errorContent) = error {
                #expect(index == 0)
                #expect(errorContent.code == 1005)
            } else {
                Issue.record("Expected batchValidationFailed error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - Batch Result Tests

    @Test("BatchDNSResult properties")
    func testBatchDNSResultProperties() {
        let successRecords = [
            ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300)),
            ARecord(name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300)),
        ]

        let errors = [
            BatchError(index: 2, error: DNSMessageContent(code: 1004, message: "Invalid record"))
        ]

        let result = BatchDNSResult(success: successRecords, errors: errors)

        #expect(result.totalOperations == 3)
        #expect(result.isPartialSuccess == true)
        #expect(result.isCompleteSuccess == false)
        #expect(result.isCompleteFailure == false)
    }

    @Test("BatchDNSResult complete success")
    func testBatchDNSResultCompleteSuccess() {
        let successRecords = [
            ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300)),
            ARecord(name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300)),
        ]

        let result = BatchDNSResult(success: successRecords, errors: [])

        #expect(result.totalOperations == 2)
        #expect(result.isCompleteSuccess == true)
        #expect(result.isPartialSuccess == false)
        #expect(result.isCompleteFailure == false)
    }

    @Test("BatchDNSResult complete failure")
    func testBatchDNSResultCompleteFailure() {
        let errors = [
            BatchError(index: 0, error: DNSMessageContent(code: 1004, message: "Invalid record 1")),
            BatchError(index: 1, error: DNSMessageContent(code: 1004, message: "Invalid record 2")),
        ]

        let result = BatchDNSResult<ARecord>(success: [], errors: errors)

        #expect(result.totalOperations == 2)
        #expect(result.isCompleteSuccess == false)
        #expect(result.isPartialSuccess == false)
        #expect(result.isCompleteFailure == true)
    }

    // MARK: - Mixed Batch Operation Tests

    @Test("MixedBatchDNSOperation initialization")
    func testMixedBatchDNSOperationInitialization() throws {
        let records = [
            AnyDNSRecord(
                ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300))),
            AnyDNSRecord(
                AAAARecord(name: "test2.example.com", content: "2001:db8::1", ttl: .seconds(300))),
        ]

        let operation = try MixedBatchDNSOperation(records: records)
        #expect(operation.records.count == 2)
    }

    @Test("MixedBatchDNSOperation validation")
    func testMixedBatchDNSOperationValidation() throws {
        let records = [
            AnyDNSRecord(
                ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300))),
            AnyDNSRecord(
                CNAMERecord(
                    name: "test2.example.com", content: "target.example.com", ttl: .seconds(300))),
        ]

        let operation = try MixedBatchDNSOperation(records: records)
        try operation.validate()  // Should not throw
    }

    // MARK: - Batch Delete Operation Tests

    @Test("BatchDeleteOperation initialization")
    func testBatchDeleteOperationInitialization() throws {
        let recordIds = ["id1", "id2", "id3"]
        let operation = try BatchDeleteOperation(recordIds: recordIds)
        #expect(operation.recordIds.count == 3)
        #expect(operation.recordIds == recordIds)
    }

    @Test("BatchDeleteOperation empty IDs")
    func testBatchDeleteOperationEmptyIds() {
        #expect(throws: DNSRequestError.emptyBatch) {
            try BatchDeleteOperation(recordIds: [])
        }
    }

    @Test("BatchDeleteOperation invalid ID")
    func testBatchDeleteOperationInvalidId() {
        let recordIds = ["id1", "", "id3"]  // Empty ID in the middle

        do {
            _ = try BatchDeleteOperation(recordIds: recordIds)
            Issue.record("Expected batchValidationFailed error")
        } catch let error as DNSRequestError {
            if case .batchValidationFailed(let index, let errorContent) = error {
                #expect(index == 1)
                #expect(errorContent.code == 1006)
            } else {
                Issue.record("Expected batchValidationFailed error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    // MARK: - Batch Create Integration Tests

    @Test("Batch create DNS records invalid zone ID")
    func testBatchCreateDNSRecordsInvalidZoneId() async throws {
        let mockClient = MockHTTPClient()
        let dnsClient = DNSClient(apiToken: "test-token", httpClient: mockClient)

        let records = [
            ARecord(name: "test.example.com", content: "192.168.1.1", ttl: .seconds(300))
        ]

        let operation = try BatchDNSOperation(records: records)

        await #expect(throws: DNSRequestError.invalidZoneId) {
            try await dnsClient.batchCreateDNSRecords(zoneId: "", operation: operation)
        }
    }

    // MARK: - Batch Update Operation Tests

    @Test("BatchUpdateOperation initialization")
    func testBatchUpdateOperationInitialization() throws {
        let updates = [
            BatchUpdateItem(
                recordId: "record1-id",
                record: ARecord(
                    name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300))
            ),
            BatchUpdateItem(
                recordId: "record2-id",
                record: ARecord(
                    name: "test2.example.com", content: "192.168.1.2", ttl: .seconds(300))
            ),
        ]

        let operation = try BatchUpdateOperation(updates: updates)
        #expect(operation.updates.count == 2)
        #expect(operation.updates[0].recordId == "record1-id")
        #expect(operation.updates[1].recordId == "record2-id")
    }

    @Test("BatchUpdateOperation empty updates")
    func testBatchUpdateOperationEmptyUpdates() {
        #expect(throws: DNSRequestError.emptyBatch) {
            try BatchUpdateOperation<ARecord>(updates: [])
        }
    }

    @Test("BatchUpdateOperation validation")
    func testBatchUpdateOperationValidation() throws {
        let updates = [
            BatchUpdateItem(
                recordId: "record1-id",
                record: ARecord(
                    name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300))
            )
        ]

        let operation = try BatchUpdateOperation(updates: updates)
        try operation.validate()  // Should not throw
    }

    @Test("BatchUpdateOperation validation empty record ID")
    func testBatchUpdateOperationValidationEmptyRecordId() throws {
        let updates = [
            BatchUpdateItem(
                recordId: "",  // Empty record ID
                record: ARecord(
                    name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300))
            )
        ]

        let operation = try BatchUpdateOperation(updates: updates)

        do {
            try operation.validate()
            Issue.record("Expected batchValidationFailed error")
        } catch let error as DNSRequestError {
            if case .batchValidationFailed(let index, let errorContent) = error {
                #expect(index == 0)
                #expect(errorContent.code == 1006)
            } else {
                Issue.record("Expected batchValidationFailed error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("MixedBatchUpdateOperation initialization")
    func testMixedBatchUpdateOperationInitialization() throws {
        let updates = [
            MixedBatchUpdateItem(
                recordId: "record1-id",
                record: AnyDNSRecord(
                    ARecord(name: "test1.example.com", content: "192.168.1.1", ttl: .seconds(300)))
            ),
            MixedBatchUpdateItem(
                recordId: "record2-id",
                record: AnyDNSRecord(
                    CNAMERecord(
                        name: "test2.example.com", content: "target.example.com", ttl: .seconds(300)
                    ))
            ),
        ]

        let operation = try MixedBatchUpdateOperation(updates: updates)
        #expect(operation.updates.count == 2)
        #expect(operation.updates[0].recordId == "record1-id")
        #expect(operation.updates[1].recordId == "record2-id")
    }

    // MARK: - Batch Delete Operation Tests (Additional)

    @Test("Batch delete DNS records invalid zone ID")
    func testBatchDeleteDNSRecordsInvalidZoneId() async throws {
        let mockClient = MockHTTPClient()
        let dnsClient = DNSClient(apiToken: "test-token", httpClient: mockClient)

        let operation = try BatchDeleteOperation(recordIds: ["record1-id"])

        await #expect(throws: DNSRequestError.invalidZoneId) {
            try await dnsClient.batchDeleteDNSRecords(zoneId: "", operation: operation)
        }
    }

    @Test("Batch update DNS records invalid zone ID")
    func testBatchUpdateDNSRecordsInvalidZoneId() async throws {
        let mockClient = MockHTTPClient()
        let dnsClient = DNSClient(apiToken: "test-token", httpClient: mockClient)

        let updates = [
            BatchUpdateItem(
                recordId: "record1-id",
                record: ARecord(
                    name: "test.example.com", content: "192.168.1.1", ttl: .seconds(300))
            )
        ]
        let operation = try BatchUpdateOperation(updates: updates)

        await #expect(throws: DNSRequestError.invalidZoneId) {
            try await dnsClient.batchUpdateDNSRecords(zoneId: "", operation: operation)
        }
    }

    @Test("Batch update mixed DNS records invalid zone ID")
    func testBatchUpdateMixedDNSRecordsInvalidZoneId() async throws {
        let mockClient = MockHTTPClient()
        let dnsClient = DNSClient(apiToken: "test-token", httpClient: mockClient)

        let updates = [
            MixedBatchUpdateItem(
                recordId: "record1-id",
                record: AnyDNSRecord(
                    ARecord(name: "test.example.com", content: "192.168.1.1", ttl: .seconds(300)))
            )
        ]
        let operation = try MixedBatchUpdateOperation(updates: updates)

        await #expect(throws: DNSRequestError.invalidZoneId) {
            try await dnsClient.batchUpdateMixedDNSRecords(zoneId: "", operation: operation)
        }
    }
}

import Foundation

/// Result structure for DNS record deletion operations
public struct DNSDeleteResult: Sendable, Codable, Hashable {
    /// The identifier of the deleted DNS record
    public let id: String
    
    /// Initialize a new DNS delete result
    /// - Parameter id: The identifier of the deleted record
    public init(id: String) {
        self.id = id
    }
}
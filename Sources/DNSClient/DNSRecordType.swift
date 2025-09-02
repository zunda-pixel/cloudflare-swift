import Foundation

/// Enumeration of all supported DNS record types
public enum DNSRecordType: String, Sendable, Codable, CaseIterable, Hashable {
    /// A record - Maps a domain name to an IPv4 address
    case a = "A"
    
    /// AAAA record - Maps a domain name to an IPv6 address
    case aaaa = "AAAA"
    
    /// CNAME record - Maps an alias name to a canonical domain name
    case cname = "CNAME"
    
    /// MX record - Mail exchange record for email routing
    case mx = "MX"
    
    /// TXT record - Text record for arbitrary text data
    case txt = "TXT"
    
    /// SRV record - Service record for service discovery
    case srv = "SRV"
    
    /// CAA record - Certification Authority Authorization
    case caa = "CAA"
    
    /// NS record - Name server record
    case ns = "NS"
    
    /// PTR record - Pointer record for reverse DNS lookups
    case ptr = "PTR"
    
    /// SOA record - Start of Authority record
    case soa = "SOA"
    
    /// DNSKEY record - DNS Key record for DNSSEC
    case dnskey = "DNSKEY"
    
    /// DS record - Delegation Signer record for DNSSEC
    case ds = "DS"
    
    /// HTTPS record - HTTPS service binding
    case https = "HTTPS"
    
    /// SVCB record - Service binding record
    case svcb = "SVCB"
    
    /// URI record - Uniform Resource Identifier record
    case uri = "URI"
    
    /// NAPTR record - Naming Authority Pointer record
    case naptr = "NAPTR"
    
    /// CERT record - Certificate record
    case cert = "CERT"
    
    /// SSHFP record - SSH Key Fingerprint record
    case sshfp = "SSHFP"
    
    /// TLSA record - Transport Layer Security Authentication record
    case tlsa = "TLSA"
    
    /// SMIMEA record - S/MIME Certificate Association record
    case smimea = "SMIMEA"
    
    /// LOC record - Location record
    case loc = "LOC"
    
    /// Whether this record type can be proxied through Cloudflare
    public var isProxiable: Bool {
        switch self {
        case .a, .aaaa, .cname:
            return true
        default:
            return false
        }
    }
    
    /// Whether this record type requires additional structured data
    public var hasStructuredData: Bool {
        switch self {
        case .mx, .srv, .caa:
            return true
        default:
            return false
        }
    }
    
    /// Human-readable description of the record type
    public var description: String {
        switch self {
        case .a:
            return "IPv4 Address"
        case .aaaa:
            return "IPv6 Address"
        case .cname:
            return "Canonical Name"
        case .mx:
            return "Mail Exchange"
        case .txt:
            return "Text Record"
        case .srv:
            return "Service Record"
        case .caa:
            return "Certification Authority Authorization"
        case .ns:
            return "Name Server"
        case .ptr:
            return "Pointer Record"
        case .soa:
            return "Start of Authority"
        case .dnskey:
            return "DNS Key"
        case .ds:
            return "Delegation Signer"
        case .https:
            return "HTTPS Service Binding"
        case .svcb:
            return "Service Binding"
        case .uri:
            return "Uniform Resource Identifier"
        case .naptr:
            return "Naming Authority Pointer"
        case .cert:
            return "Certificate"
        case .sshfp:
            return "SSH Key Fingerprint"
        case .tlsa:
            return "Transport Layer Security Authentication"
        case .smimea:
            return "S/MIME Certificate Association"
        case .loc:
            return "Location"
        }
    }
}
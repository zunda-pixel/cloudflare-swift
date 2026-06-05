import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct EmailMessage: Sendable, Codable, Hashable {
  public var to: RecipientList
  public var cc: [String]? = nil
  public var bcc: [String]? = nil
  public var from: Sender
  public var replyTo: String? = nil
  public var subject: String
  public var html: String? = nil
  public var text: String? = nil
  public var attachments: [Attachment]? = nil
  public var headers: [String: String]? = nil

  public init(
    to: String,
    from: String,
    subject: String,
    html: String? = nil,
    text: String? = nil
  ) {
    self.init(
      to: .single(to),
      from: .address(from),
      subject: subject,
      html: html,
      text: text
    )
  }

  private enum CodingKeys: String, CodingKey {
    case to
    case cc
    case bcc
    case from
    case replyTo = "reply_to"
    case subject
    case html
    case text
    case attachments
    case headers
  }
}

public enum RecipientList: Sendable, Codable, Hashable {
  case single(String)
  case many([String])

  public init(_ recipients: [String]) {
    if recipients.count == 1, let recipient = recipients.first {
      self = .single(recipient)
    } else {
      self = .many(recipients)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .single(let recipient):
      try container.encode(recipient)
    case .many(let recipients):
      try container.encode(recipients)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let recipient = try? container.decode(String.self) {
      self = .single(recipient)
    } else {
      self = .many(try container.decode([String].self))
    }
  }
}

public enum Sender: Sendable, Codable, Hashable {
  case address(String)
  case named(address: String, name: String)

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .address(let address):
      try container.encode(address)
    case .named(let address, let name):
      try container.encode(NamedSender(address: address, name: name))
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let address = try? container.decode(String.self) {
      self = .address(address)
    } else {
      let namedSender = try container.decode(NamedSender.self)
      self = .named(address: namedSender.address, name: namedSender.name)
    }
  }

  private struct NamedSender: Sendable, Codable, Hashable {
    var address: String
    var name: String
  }
}

@MemberwiseInit(.public)
public struct Attachment: Sendable, Codable, Hashable {
  public var content: String
  public var filename: String
  public var type: String
  public var disposition: String? = nil
}

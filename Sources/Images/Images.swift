import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartForm

extension JSONDecoder {
  static let images: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions.insert(.withFractionalSeconds)
      
      return formatter.date(from: string)!
    }
    
    return decoder
  }()
}

public struct ImageClient {
  public let token: String
  public let accountId: String
  
  public init(
    token: String,
    accountId: String
  ) {
    self.token = token
    self.accountId = accountId
  }
  
  private func upload(
    imageData: MultipartForm.Part,
    id: String?,
    metadatas: [String: String],
    requireSignedURLs: Bool
  ) async throws -> ImagesResponse.Result {
    let url = URL(string: "https://api.cloudflare.com/client/v4/accounts/\(accountId)/images/v1")!
    let request = HTTPRequest(
      method: .post,
      url: url,
      headerFields: HTTPFields(dictionaryLiteral: (.authorization, "Bearer \(token)"), (.contentType, "multipart/form-data"))
    )

    let metadatas = try! String(decoding: JSONEncoder().encode(metadatas), as: UTF8.self)
    var form = MultipartForm(parts: [
      imageData,
      MultipartForm.Part(name: "metadata", value: metadatas),
      MultipartForm.Part(name: "requireSignedURLs", value: requireSignedURLs.description),
    ])
    id.map { form.parts.append(.init(name: "id", value: $0)) }

    var urlReqeust = URLRequest(httpRequest: request)!
    urlReqeust.setValue(form.contentType, forHTTPHeaderField: "Content-Type")

    let (data, _) = try await URLSession.shared.upload(for: urlReqeust, from: form.bodyData)
    
    let response = try JSONDecoder.images.decode(ImagesResponse.self, from: data)
    
    if response.success {
      return response.result!
    } else {
      throw handleError(errors: response.errors)
    }
  }
  
  
  public func upload(
    data: Data,
    id: String? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool = false
  ) async throws -> ImagesResponse.Result {
    return try await self.upload(
      imageData: MultipartForm.Part(name: "file",data: data),
      id: id,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }
  
  public func upload(
    url: URL,
    id: String? = nil,
    metadatas: [String: String] = [:],
    requireSignedURLs: Bool = false
  ) async throws -> ImagesResponse.Result {
    return try await self.upload(
      imageData: MultipartForm.Part(name: "url", value: url.absoluteString),
      id: id,
      metadatas: metadatas,
      requireSignedURLs: requireSignedURLs
    )
  }
  
  private func handleError(errors: [ErrorContent]) -> RequestError {
    if errors.map(\.code).contains(5411) {
      return RequestError.invalidCustomId
    }
    else if errors.map(\.code).contains(5455) {
      return RequestError.invalidContentType
    }
    else if let error = errors.first(where: { $0.code == 5454 }) {
      return RequestError.failedFetch(message: error.message)
    }
    else if let error = errors.first(where: { $0.code == 7003 }) {
      return RequestError.couldNotRoute(message: error.message)
    }
    else if errors.map(\.code).contains(10000) {
      return RequestError.authentication
    }
    else {
      return RequestError.unknown(contents: errors)
    }
  }
}

enum RequestError: Error {
  /// Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  case invalidContentType
  case authentication
  case couldNotRoute(message: String)
  case failedFetch(message: String)
  /// The Custom ID is invalid. Custom IDs can include 1024 characters or less, any number of subpaths, and support the UTF-8 encoding standard for characters. Enter a new Custom ID and try again: Must not be UUID
  case invalidCustomId
  case unknown(contents: [ErrorContent])
}

public struct ErrorContent: Error, Sendable, Codable, Hashable {
  public var code: Int
  public var message: String
}

public struct ImagesResponse: Sendable, Codable, Hashable {
  public var result: Result?
  public var success: Bool
  public var errors: [ErrorContent]
  public var messages: [String]
  
  public struct Result: Sendable, Codable, Hashable {
    public var id: String
    public var fileName: String?
    public var metadatas: [String: String]?
    public var uploadedDate: Date
    public var requireSignedURLs: Bool
    public var variants: [URL]
    
    private enum CodingKeys: String, CodingKey {
      case id
      case fileName = "filename"
      case metadatas = "meta"
      case uploadedDate = "uploaded"
      case requireSignedURLs
      case variants
    }
  }
}

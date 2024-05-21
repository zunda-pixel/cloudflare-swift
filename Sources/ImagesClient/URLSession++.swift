import Foundation
import HTTPTypes
import HTTPTypesFoundation

extension URLSession: HTTPClientProtocol {
  public func execute(_ request: HTTPRequest, body: Data?) async throws -> (Data, HTTPResponse) {
    if let body {
      try await self.upload(for: request, from: body)
    } else {
      try await self.data(for: request)
    }
  }
}

extension HTTPClientProtocol where Self == URLSession {
  public static func urlSession(_ urlSession: Self) -> Self {
    return urlSession
  }
}

#if canImport(FoundationNetworking)
  import FoundationNetworking
  @preconcurrency import Foundation

  extension URLSession {
    public func data(
      for request: URLRequest,
      delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        let task = self.dataTask(with: request) { (data, response, error) in
          guard let data = data, let response = response else {
            let error = error ?? URLError(.badServerResponse)
            return continuation.resume(throwing: error)
          }
          continuation.resume(returning: (data, response))
        }
        task.resume()
      }
    }

    public func data(
      for request: HTTPRequest,
      delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, HTTPResponse) {
      guard let urlRequest = URLRequest(httpRequest: request) else {
        throw HTTPTypeConversionError.failedToConvertHTTPRequestToURLRequest
      }
      let (data, urlResponse) = try await self.data(for: urlRequest, delegate: delegate)
      guard let response = (urlResponse as? HTTPURLResponse)?.httpResponse else {
        throw HTTPTypeConversionError.failedToConvertURLResponseToHTTPResponse
      }
      return (data, response)
    }

    public func upload(
      for request: URLRequest,
      from data: Data,
      delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        let task = self.uploadTask(with: request, from: data) { (data, response, error) in
          guard let data = data, let response = response else {
            let error = error ?? URLError(.badServerResponse)
            return continuation.resume(throwing: error)
          }
          continuation.resume(returning: (data, response))
        }
        task.resume()
      }
    }

    public func upload(
      for request: HTTPRequest,
      from data: Data,
      delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, HTTPResponse) {
      guard let urlRequest = URLRequest(httpRequest: request) else {
        throw HTTPTypeConversionError.failedToConvertHTTPRequestToURLRequest
      }
      let (data, urlResponse) = try await self.upload(for: urlRequest, from: data)
      guard let response = (urlResponse as? HTTPURLResponse)?.httpResponse else {
        throw HTTPTypeConversionError.failedToConvertURLResponseToHTTPResponse
      }
      return (data, response)
    }
  }

  enum HTTPTypeConversionError: Error {
    case failedToConvertHTTPRequestToURLRequest
    case failedToConvertURLResponseToHTTPResponse
  }
#endif

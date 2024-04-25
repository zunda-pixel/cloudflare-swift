import Foundation
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
  @preconcurrency import Foundation

  extension URLSession {
    public func data(
      for request: URLRequest,
      delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        self.dataTask(with: request) { data, response, error in
          if let error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume(returning: (data!, response!))
          }
        }
        .resume()
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
  }

  enum HTTPTypeConversionError: Error {
    case failedToConvertHTTPRequestToURLRequest
    case failedToConvertURLResponseToHTTPResponse
  }
#endif

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension ImagesClient {
  /// Upload Image Data to Cloudflare Images with Upload URL
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-create-authenticated-direct-upload-url-v-2
  /// - Parameters:
  ///   - uploadURL: Upload URL
  ///   - imageData: Image Data
  /// - Returns: ``Image``
  static private func upload(
    uploadURL: URL,
    imageData: ImageBody
  ) async throws -> Image {
    let boundary = UUID().uuidString
    let formData = try FormDataEncoder().encode(imageData, boundary: boundary)

    let request = HTTPRequest(
      method: .post,
      url: uploadURL,
      headerFields: HTTPFields(dictionaryLiteral: (.contentType, "multipart/form-data; boundary=\(boundary)"))
    )

    let (data, _) = try await URLSession.shared.upload(for: request, from: Data(formData.utf8))
    let response = try JSONDecoder.images.decode(ImagesResponse<Image>.self, from: data)

    if let result = response.result, response.success {
      return result
    } else {
      throw handleError(errors: response.errors)
    }
  }

  /// Upload Image Data to Cloudflare Images with Upload URL
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-create-authenticated-direct-upload-url-v-2
  /// - Parameters:
  ///   - uploadURL: Upload URL
  ///   - imageData: Image Data
  /// - Returns: ``Image``
  static public func upload(
    uploadURL: URL,
    imageData: Data
  ) async throws -> Image {
    return try await self.upload(
      uploadURL: uploadURL,
      imageData: .file(imageData)
    )
  }

  /// Upload Image Data from URL to Cloudflare Images with Upload URL
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-create-authenticated-direct-upload-url-v-2
  /// - Parameters:
  ///   - uploadURL: Upload URL
  ///   - imageURL: Image URL
  /// - Returns: ``Image``
  static public func upload(
    uploadURL: URL,
    imageURL: URL
  ) async throws -> Image {
    return try await self.upload(
      uploadURL: uploadURL,
      imageData: .url(imageURL)
    )
  }
}

enum ImageBody: Encodable {
  case url(URL)
  case file(Data)
  
  private enum CodingKeys: CodingKey {
    case url
    case file
  }
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .url(let url):
      try container.encode(url.absoluteString, forKey: .url)
    case .file(let file):
      try container.encode(file, forKey: .file)
    }
  }
}

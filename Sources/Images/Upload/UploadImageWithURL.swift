import Foundation
import HTTPTypes
import HTTPTypesFoundation
import MultipartForm

extension ImageClient {
  /// Upload Image Data to Cloudflare Images with Upload URL
  /// https://developers.cloudflare.com/api/operations/cloudflare-images-create-authenticated-direct-upload-url-v-2
  /// - Parameters:
  ///   - uploadURL: Upload URL
  ///   - imageData: Image Data
  /// - Returns: ``Image``
  static private func upload(
    uploadURL: URL,
    imageData: MultipartForm.Part
  ) async throws -> Image {
    let form = MultipartForm(parts: [imageData])

    let request = HTTPRequest(
      method: .post,
      url: uploadURL,
      headerFields: HTTPFields(dictionaryLiteral: (.contentType, form.contentType))
    )

    let (data, _) = try await URLSession.shared.upload(for: request, from: form.bodyData)
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
      imageData: MultipartForm.Part(name: "file", data: imageData)
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
      imageData: MultipartForm.Part(name: "url", value: imageURL.absoluteString)
    )
  }
}

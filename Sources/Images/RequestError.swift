public enum RequestError: Error {
  /// The image contains a custom ID and cannot be set to private. To make the image private, delete and upload the image again using a regular ID.
  case privateImageCantSetCustomID
  /// Uploaded image must have image/jpeg, image/png, image/webp, image/gif or image/svg+xml content-type
  case invalidContentType
  case invalidAuthentication
  case couldNotRoute(message: String)
  case failedFetch(message: String)
  /// The Custom ID is invalid. Custom IDs can include 1024 characters or less, any number of subpaths, and support the UTF-8 encoding standard for characters. Enter a new Custom ID and try again: Must not be UUID
  case invalidCustomId
  case failedDelete
  case unknown(errors: [MessageContent])
}

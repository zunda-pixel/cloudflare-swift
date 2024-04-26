extension ImagesClient {
  static func handleError(errors: [MessageContent]) -> RequestError {
    if errors.map(\.code).contains(5410) {
      return RequestError.privateImageCantSetCustomID
    } else if errors.map(\.code).contains(5411) {
      return RequestError.invalidCustomId
    } else if errors.map(\.code).contains(5455) {
      return RequestError.invalidContentType
    } else if let error = errors.first(where: { $0.code == 5454 }) {
      return RequestError.failedFetch(message: error.message)
    } else if let error = errors.first(where: { $0.code == 7003 }) {
      return RequestError.couldNotRoute(message: error.message)
    } else if errors.map(\.code).contains(10000) {
      return RequestError.invalidAuthentication
    } else {
      return RequestError.unknown(errors: errors)
    }
  }
}

extension Client {
  static func handleError(errors: [MessageContent]) -> RequestError {
    if errors.map(\.code).contains(10000) {
      return .invalidAuthentication
    } else if errors.map(\.code).contains(10001) {
      return .invalidRequestSchema
    } else if errors.map(\.code).contains(10200) {
      return .invalidEmail
    } else if errors.map(\.code).contains(10201) {
      return .missingContentLength
    } else if errors.map(\.code).contains(10202) {
      return .tooBig
    } else if errors.map(\.code).contains(10203) {
      return .sendingDisabled
    } else if errors.map(\.code).contains(10004) {
      return .throttled
    } else if errors.map(\.code).contains(10002) {
      return .internalServer
    } else {
      return .unknown(errors: errors)
    }
  }
}

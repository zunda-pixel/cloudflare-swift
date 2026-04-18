public enum RequestError: Error {
  case invalidAuthentication
  case invalidRequestSchema
  case invalidEmail
  case missingContentLength
  case tooBig
  case sendingDisabled
  case throttled
  case internalServer
  case unknown(errors: [MessageContent])
}

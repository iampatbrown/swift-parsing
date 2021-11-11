public struct TraceEvent: CustomDebugStringConvertible {
  var parserID: String
  var input: Any
  var depth: Int
  var type: EventType
  var file: StaticString
  var line: UInt

  public enum EventType {
    case start
    case fail
    case success(Any)
  }

  @usableFromInline
  internal init(
    parserID: String,
    input: Any,
    depth: Int,
    type: TraceEvent.EventType,
    file: StaticString,
    line: UInt
  ) {
    self.parserID = parserID
    self.input = input
    self.depth = depth
    self.type = type
    self.file = file
    self.line = line
  }

  public var debugDescription: String {
    switch self.type {
    case .start:
      return "\(self.parserID)\tInput(\(parserDebug(for: self.input)))"
    case .fail:
      return "-> Fail@\(self.file):\(self.line)"
    case let .success(output):
      return "-> Output(\(parserDebug(for: output)))"
    }
  }
}

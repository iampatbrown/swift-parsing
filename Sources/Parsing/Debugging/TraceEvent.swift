public struct TraceEvent: CustomStringConvertible {
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

  public var description: String {
    let indentation = String(repeating: " ", count: self.depth * 2)
    switch self.type {
    case .start:
      return "\(indentation)\(self.parserID)\tInput(\(self.input))"
    case .fail:
      return "\(indentation)-> Fail@\(self.file):\(self.line)"
    case let .success(output):
      return "\(indentation)-> Output(\(output))"
    }
  }
}

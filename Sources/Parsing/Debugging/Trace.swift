

public struct Trace {
  var events: [TraceEvent] = []
  var depth: Int = 0

  @usableFromInline
  mutating func start<P: Parser>(
    for parser: TracedParser<P>,
    input: P.Input
  ) {
    self.events.append(
      TraceEvent(
        parserID: parser.parserID,
        input: input,
        depth: self.depth,
        type: .start,
        file: parser.file,
        line: parser.line
      )
    )
    self.depth += 1
  }

  @usableFromInline
  mutating func success<P: Parser>(
    for parser: TracedParser<P>,
    input: P.Input,
    output: P.Output
  ) {
    self.depth -= 1
    self.events.append(
      TraceEvent(
        parserID: parser.parserID,
        input: input,
        depth: self.depth,
        type: .success(output),
        file: parser.file,
        line: parser.line
      )
    )
  }

  @usableFromInline
  mutating func fail<P: Parser>(
    for parser: TracedParser<P>,
    input: P.Input
  ) {
    self.depth -= 1
    self.events.append(
      TraceEvent(
        parserID: parser.parserID,
        input: input,
        depth: self.depth,
        type: .fail,
        file: parser.file,
        line: parser.line
      )
    )
  }

  public mutating func clear() {
    self.events = []
  }

  public func print<TargetStream>(
    to target: inout TargetStream
  ) where TargetStream: TextOutputStream {
    for event in self.events {
      let indentation = String(repeating: " ", count: event.depth * 2)
      target.write("\(indentation)\(event)\n")
    }
  }

  public func print() {
    var target = ""
    self.print(to: &target)
    Swift.print(target)
  }

  public static var `default`: Self {
    get { Self["default"] }
    set { Self["default"] = newValue }
  }

  @usableFromInline
  static var traces: [String: Trace] = ["default": Trace()]

  @usableFromInline
  static subscript(groupID: String) -> Trace {
    get {
      if Self.traces[groupID] == nil { Self.traces[groupID] = Trace() }
      return Self.traces[groupID]!
    }
    set {
      Self.traces[groupID] = newValue
    }
  }
}

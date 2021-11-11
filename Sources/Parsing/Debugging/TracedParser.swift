public struct TracedParser<Upstream>: ModifiedParser where Upstream: Parser {
  public let upstream: Upstream
  public let parserID: String
  public let groupID: String
  public let file: StaticString
  public let line: UInt

  internal init(
    upstream: Upstream,
    parserID: String? = nil,
    groupID: String = "default",
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.upstream = upstream
    self.parserID = parserID ?? String("\(type(of: upstream))".prefix(while: { $0 != "<" }))
    self.groupID = groupID
    self.file = file
    self.line = line
  }

  @inlinable
  public var body: AnyParser<Upstream.Input, Upstream.Output> {
    AnyParser<Upstream.Input, Upstream.Output> { input in
      Trace[self.groupID].start(for: self, input: input)
      if let output = self.upstream.parse(&input) {
        Trace[self.groupID].success(for: self, input: input, output: output)
        return output
      } else {
        Trace[self.groupID].fail(for: self, input: input)
        return nil
      }
    }
  }
}

extension Parser {
  public func trace(
    _ parserID: String? = nil,
    groupID: String = "default",
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> TracedParser<Self> {
    TracedParser(upstream: self, parserID: parserID, groupID: groupID, file: file, line: line)
  }
}


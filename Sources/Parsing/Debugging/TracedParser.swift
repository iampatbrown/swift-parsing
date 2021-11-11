
public struct TracedParser<Upstream>: ParserModifier where Upstream: Parser {
  public let parserID: String
  public let groupID: String
  public let file: StaticString
  public let line: UInt

  internal init(
    parserID: String? = nil,
    groupID: String = "default",
    file: StaticString = #fileID,
    line: UInt = #line
  ) {
    self.parserID = parserID ?? "Parser<\(Upstream.Input.self), \(Upstream.Output.self)>"
    self.groupID = groupID
    self.file = file
    self.line = line
  }


  @inlinable
  public func body(upstream: AnyParser<Upstream.Input, Upstream.Output>) -> AnyParser<Upstream.Input, Upstream.Output> {
    AnyParser { input in
      Trace[self.groupID].start(for: self, input: input)
      if let output = upstream.parse(&input) {
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
  ) -> ModifiedParser<Self, TracedParser<Self>> {

    let parserID = parserID ?? String("\(type(of: Self.self))".prefix(while: { $0 != "<"}))

    return self.modifier(TracedParser(parserID: parserID, groupID: groupID, file: file, line: line))
  }
}

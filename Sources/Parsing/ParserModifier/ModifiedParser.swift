public protocol ModifiedParser: Parser where Input == Body.Input, Output == Body.Output {
  associatedtype Body: Parser
  associatedtype Upstream: Parser
  var upstream: Upstream { get }
  @ParserBuilder var body: Body { get }
}

extension ModifiedParser {
  @inlinable @inline(__always)
  public func parse(_ input: inout Body.Input) -> Body.Output? {
    self.body.parse(&input)
  }
}

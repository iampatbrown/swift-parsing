public protocol ParserModifier {
  associatedtype Body: Parser
  associatedtype Upstream: Parser
  func body(upstream: AnyParser<Upstream.Input, Upstream.Output>) -> Self.Body
}

extension Parser {
  public func modifier<Modifier>(_ modifier: Modifier) -> ModifiedParser<Self, Modifier>
    where
    Input == Modifier.Upstream.Input,
    Output == Modifier.Upstream.Output
  {
    .init(upstream: self, modifier: modifier)
  }
}

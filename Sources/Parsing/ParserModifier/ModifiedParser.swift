public struct ModifiedParser<Upstream, Modifier>: Parser
  where
  Upstream: Parser,
  Modifier: ParserModifier,
  Upstream.Input == Modifier.Upstream.Input,
  Upstream.Output == Modifier.Upstream.Output
{
  @usableFromInline
  let upstream: AnyParser<Upstream.Input, Upstream.Output>

  @usableFromInline
  let modifier: Modifier

  @usableFromInline
  internal init(upstream: Upstream, modifier: Modifier) {
    self.upstream = upstream.eraseToAnyParser()
    self.modifier = modifier
  }

  @inlinable @inline(__always)
  public func parse(_ input: inout Modifier.Body.Input) -> Modifier.Body.Output? {
    self.modifier.body(upstream: self.upstream).parse(&input)
  }
}

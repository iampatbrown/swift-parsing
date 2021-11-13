public struct FromUTF8View<UTF8Parser>: Parser
  where
  UTF8Parser: Parser,
  UTF8Parser.Input == Substring.UTF8View
{
  public let utf8Parser: UTF8Parser

  @inlinable
  public init(@ParserBuilder _ utf8Parser: () -> UTF8Parser) {
    self.utf8Parser = utf8Parser()
  }

  @inlinable
  public func parse(_ input: inout Substring) -> UTF8Parser.Output? {
    self.utf8Parser.parse(&input.utf8)
  }
}

extension FromUTF8View: Printer where UTF8Parser: Printer {
  @inlinable
  @inline(__always)
  public func print(_ output: UTF8Parser.Output) -> Substring? {
    self.utf8Parser.print(output).map(Substring.init)
  }
}


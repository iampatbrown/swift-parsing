import Parsing

public struct Path<ComponentParser>: ParserPrinter
  where
  ComponentParser: ParserPrinter,
  ComponentParser.Input == Substring
{
  public let componentParser: ComponentParser

  @inlinable
  public init(_ string: String) where ComponentParser == FromUTF8View<String.UTF8View> {
    self.componentParser = FromUTF8View { string.utf8 }
  }

  @inlinable
  public init(@ParserBuilder _ build: () -> ComponentParser) {
    self.componentParser = build()
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> ComponentParser.Output? {
    guard
      var component = input.path.first,
      let output = self.componentParser.parse(&component),
      component.isEmpty
    else { return nil }

    input.path.removeFirst()
    return output
  }

  @inlinable
  public func print(_ output: ComponentParser.Output) -> URLRequestData? {
    .init(path: self.componentParser.print(output).map { [$0] } ?? [])
  }
}


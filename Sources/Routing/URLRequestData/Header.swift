import Parsing

public struct Header<ValueParser>: ParserPrinter
  where
  ValueParser: ParserPrinter,
  ValueParser.Input == Substring
{
  public let name: String
  public let valueParser: ValueParser

  @inlinable
  public init(
    _ name: String,
    _ value: ValueParser
  ) {
    self.name = name
    self.valueParser = value
  }

  @inlinable
  public init(_ name: String) where ValueParser == Rest<Substring> {
    self.init(name, Rest())
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> ValueParser.Output? {
    guard
      var value = input.headers[self.name],
      let output = self.valueParser.parse(&value),
      value.isEmpty
    else { return nil }

    input.headers[self.name]?.removeFirst()
    return output
  }

  @inlinable
  public func print(_ output: ValueParser.Output) -> URLRequestData? {
    guard let value = self.valueParser.print(output)
    else { return nil }
    return .init(headers: [self.name: value])
  }
}

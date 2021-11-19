import Parsing

public struct Query<ValueParser>: ParserPrinter
  where
  ValueParser: ParserPrinter,
  ValueParser.Input == Substring
{
  public let defaultValue: ValueParser.Output?
  public let name: String
  public let valueParser: ValueParser

  @inlinable
  public init(
    _ name: String,
    _ value: ValueParser,
    default defaultValue: ValueParser.Output? = nil
  ) {
    self.defaultValue = defaultValue
    self.name = name
    self.valueParser = value
  }

  @inlinable
  public init(
    _ name: String,
    default defaultValue: ValueParser.Output? = nil
  ) where ValueParser == Rest<Substring> {
    self.init(
      name,
      Rest(),
      default: defaultValue
    )
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> ValueParser.Output? {
    guard
      let wrapped = input.query[self.name]?.first,
      var value = wrapped,
      let output = self.valueParser.parse(&value),
      value.isEmpty
    else { return defaultValue }

    input.query[self.name]?.removeFirst()
    if input.query[self.name]?.isEmpty ?? true {
      input.query[self.name] = nil
    }
    return output
  }

  @inlinable
  public func print(_ output: ValueParser.Output) -> URLRequestData? {
    guard let value = self.valueParser.print(output) else { return nil }
    return .init(query: [self.name: [value]])
  }
}

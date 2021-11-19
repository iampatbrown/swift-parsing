import Parsing

public struct Body<BodyParser>: ParserPrinter
  where
  BodyParser: ParserPrinter,
  BodyParser.Input == ArraySlice<UInt8>
{
  public let bodyParser: BodyParser

  @inlinable
  public init(@ParserBuilder _ bodyParser: () -> BodyParser) {
    self.bodyParser = bodyParser()
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> BodyParser.Output? {
    guard
      var body = input.body,
      let output = self.bodyParser.parse(&body),
      body.isEmpty
    else { return nil }

    input.body = nil
    return output
  }

  @inlinable
  public func print(_ output: BodyParser.Output) -> URLRequestData? {
    guard let body = self.bodyParser.print(output)
    else { return nil }
    return .init(body: body)
  }
}

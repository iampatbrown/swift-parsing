import CasePaths

public struct __Routing<Route>: ParserPrinter {
  @usableFromInline
  let parser: (inout URLRequestData) -> Route?
  @usableFromInline
  let printer: (Route) -> URLRequestData?

  @usableFromInline
  init(
    parse: @escaping (inout URLRequestData) -> Route?,
    print: @escaping (Route) -> URLRequestData?
  ) {
    self.parser = parse
    self.printer = print
  }

  @inlinable
  public init(@__RoutingBuilder _ router: () -> Self) {
    self = router()
  }

  @inlinable
  public init<Value, RouteParser>(
    _ route: CasePath<Route, Value>,
    @ParserBuilder to parser: () -> RouteParser
  )
    where
    RouteParser: ParserPrinter,
    RouteParser.Input == URLRequestData,
    RouteParser.Output == Value
  {
    let parser = Zip2_OV(parser().map(route), PathEnd())
    self.parser = parser.parse
    self.printer = parser.print
  }

  @inlinable
  public init(
    _ route: CasePath<Route, Void>
  ) {
    let parser = Zip2_OV(Always<URLRequestData, Void>(()).map(route), PathEnd())
    self.parser = parser.parse
    self.printer = parser.print
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Route? {
    self.parser(&input)
  }

  @inlinable
  public func print(_ output: Route) -> URLRequestData? {
    self.printer(output)
  }
}

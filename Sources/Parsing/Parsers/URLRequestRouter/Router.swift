public struct Router<Route>: ParserPrinter {
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
  public init(@RouterBuilder _ router: () -> Self) {
    self = router()
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



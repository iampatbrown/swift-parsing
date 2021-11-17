import CasePaths
public struct _Router<Route>: ParserPrinter {
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
  public init(@_RouterBuilder _ router: () -> Self) {
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

extension _Router: ExpressibleByArrayLiteral {
  @inlinable
  public init(arrayLiteral routers: _Routing<Route>...) {
    self.init(
      parse: { input in
        for router in routers {
          if let output = router.parse(&input) {
            return output
          }
        }
        return nil
      }, print: { output in
        for router in routers {
          if let input = router.print(output) {
            return input
          }
        }
        return nil
      }
    )
  }
}


public struct _Routing<Route>: ParserPrinter {
  @usableFromInline
  let parser: (inout URLRequestData) -> Route?
  @usableFromInline
  let printer: (Route) -> URLRequestData?

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
//
//  @inlinable
//  public init<RouteParser>(
//    _ route: CasePath<Route, Void>,
//    @ParserBuilder to parser: () -> RouteParser
//  ) where
//    RouteParser: ParserPrinter,
//    RouteParser.Input == URLRequestData,
//    RouteParser.Output == Void
//  {
//    let parser = Zip2_OV(parser().map(route), PathEnd())
//    self.parser = parser.parse
//    self.printer = parser.print
//  }

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

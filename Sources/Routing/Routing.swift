import CasePaths
import Foundation
import Parsing

public struct Routing<Route>: ParserPrinter {
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
  public init(@RoutingBuilder _ build: () -> Self) {
    self = build()
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
    let parser = parser()
    self.parser = { input in
      let original = input
      guard let value = parser.parse(&input), input.path.isEmpty
      else {
        input = original
        return nil
      }
      return route.embed(value)
    }

    self.printer = { output in
      guard let value = route.extract(from: output), let request = parser.print(value)
      else { return nil }
      return request
    }
  }

  @inlinable
  public init(
    _ route: CasePath<Route, Void>
  ) {
    self.parser = { _ in route.embed(()) }
    self.printer = { _ in .init() }
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Route? {
    self.parser(&input)
  }

  @inlinable
  public func print(_ output: Route) -> URLRequestData? {
    self.printer(output)
  }

  public func match(request: URLRequest) -> Route? {
    guard var input = URLRequestData(request: request) else { return nil }
    return self.parser(&input)
  }

  public func match(url: URL) -> Route? {
    return self.match(request: URLRequest(url: url))
  }

  public func match(string: String) -> Route? {
    return URL(string: string).flatMap(self.match(url:))
  }

  public func request(for route: Route) -> URLRequest? {
    return self.request(for: route, base: nil)
  }

  public func request(for route: Route, base: URL? = nil) -> URLRequest? {
    return self.print(route).flatMap { URLRequest(data: $0, base: base) }
  }

  public func url(for route: Route) -> URL? {
    return self.print(route).flatMap(URLRequest.init).flatMap(\.url)
  }

  public func url(for route: Route, base: URL?) -> URL? {
    return self.print(route).flatMap { URLRequest(data: $0, base: base) }.flatMap(\.url)
  }

  public func absoluteString(for route: Route) -> String? {
    return (self.url(for: route)?.absoluteString).map { $0 == "/" ? "/" : "/" + $0 }
  }
}

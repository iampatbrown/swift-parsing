import CasePaths
import Foundation

public struct URLRequestData: Equatable {
  public var body: ArraySlice<UInt8>?
  public var headers: [String: Substring]
  public var method: String?
  public var path: ArraySlice<Substring>
  public var query: [String: ArraySlice<Substring?>]

  @inlinable
  public init(
    method: String? = nil,
    path: ArraySlice<Substring> = [],
    query: [String: ArraySlice<Substring?>] = [:],
    headers: [String: Substring] = [:],
    body: ArraySlice<UInt8>? = nil
  ) {
    self.method = method
    self.path = path
    self.query = query
    self.headers = headers
    self.body = body
  }
}

extension URLRequestData: Appendable {
  // self.init() could probably be used
  @inlinable
  public init() {
    self.method = nil
    self.path = []
    self.query = [:]
    self.headers = [:]
    self.body = nil
  }

  @inlinable
  public mutating func append(contentsOf other: URLRequestData) {
//    self.body?.append(contentsOf: other.body ?? [])
    if let otherBody = other.body { // TODO: maybe?
      if self.body != nil {
        self.body!.append(contentsOf: otherBody)
      } else {
        self.body = otherBody
      }
    }
    self.headers.append(contentsOf: other.headers)
    self.method = self.method ?? other.method
    self.path.append(contentsOf: other.path)
    self.query.append(contentsOf: other.query)
  }
}

public struct Body<BodyParser>: Parser
  where
  BodyParser: Parser,
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
}

extension Body: Printer where BodyParser: Printer {
  @inlinable
  @inline(__always)
  public func print(_ output: BodyParser.Output) -> URLRequestData? {
    guard let body = self.bodyParser.print(output)
    else { return nil }
    return .init(body: body)
  }
}

public struct Header<ValueParser>: Parser
  where
  ValueParser: Parser,
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
}

extension Header: Printer where ValueParser: Printer {
  @inlinable
  public func print(_ output: ValueParser.Output) -> URLRequestData? {
    guard let value = self.valueParser.print(output)
    else { return nil }
    return .init(headers: [self.name: value])
  }
}

public struct JSON<Value: Decodable>: Parser {
  public let decoder: JSONDecoder
  public let encoder: JSONEncoder

  @inlinable
  public init(
    _ type: Value.Type,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.decoder = decoder
    self.encoder = encoder
  }

  @inlinable
  public func parse(_ input: inout ArraySlice<UInt8>) -> Value? {
    guard
      let output = try? decoder.decode(Value.self, from: Data(input))
    else { return nil }
    input = []
    return output
  }
}

extension JSON: Printer where Value: Encodable {
  @inlinable
  @inline(__always)
  public func print(_ output: Value) -> ArraySlice<UInt8>? {
    guard let json = try? encoder.encode(output)
    else { return nil }
    return ArraySlice(json)
  }
}

public struct Method: Parser {
  public let name: String

  public static let get = Self("GET")
  public static let post = Self("POST")
  public static let put = Self("PUT")
  public static let patch = Self("PATCH")
  public static let delete = Self("DELETE")

  @inlinable
  public init(_ name: String) {
    self.name = name.uppercased()
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Void? {
    guard input.method?.uppercased() == self.name else { return nil }
    input.method = nil
    return ()
  }
}

extension Method: Printer {
  @inlinable
  public func print(_ output: Void) -> URLRequestData? {
    .init(method: self.name)
  }
}

public struct Path<ComponentParser>: Parser
  where
  ComponentParser: Parser,
  ComponentParser.Input == Substring
{
  public let componentParser: ComponentParser

  @inlinable
  public init(_ component: ComponentParser) {
    self.componentParser = component
  }

  @inlinable
  public init(literal string: String) where ComponentParser == FromUTF8View<String.UTF8View> {
    self.componentParser = FromUTF8View { string.utf8 }
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
}

extension Path: Printer where ComponentParser: Printer {
  @inlinable
  public func print(_ output: ComponentParser.Output) -> URLRequestData? {
    .init(path: self.componentParser.print(output).map { [$0] } ?? [])
  }
}

public struct PathEnd: Parser {
  @inlinable
  public init() {}

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Void? {
    guard input.path.isEmpty
    else { return nil }
    return ()
  }
}

extension PathEnd: Printer {
  @inlinable
  public func print(_ output: Void) -> URLRequestData? {
    .init()
  }
}

public struct Query<ValueParser>: Parser
  where
  ValueParser: Parser,
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
}

extension Query: Printer where ValueParser: Printer {
  @inlinable
  public func print(_ output: ValueParser.Output) -> URLRequestData? {
    guard let value = self.valueParser.print(output) else { return nil }
    return .init(query: [self.name: [value]])
  }
}

public struct Routing<RouteParser, Route>: Parser
  where
  RouteParser: Parser,
  RouteParser.Input == URLRequestData
{
  public let parser: Zip2_OV<Parsers.MapViaParser<RouteParser, CasePath<Route, RouteParser.Output>>, PathEnd>

  @inlinable
  public init(
    _ route: CasePath<Route, RouteParser.Output>,
    @ParserBuilder to parser: () -> RouteParser
  ) {
    self.parser = Zip2_OV(parser().map(route), PathEnd())
  }

  @inlinable
  public init(
    _ route: CasePath<Route, Void>,
    @ParserBuilder to parser: () -> RouteParser
  ) where RouteParser.Output == Void {
    self.parser = Zip2_OV(parser().map(route), PathEnd())
  }

  @inlinable
  public init(
    _ route: CasePath<Route, Void>
  ) where RouteParser == Always<URLRequestData, Void> {
    self.init(route, to: { Always<URLRequestData, Void>(()) })
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Route? {
    self.parser.parse(&input)
  }
}

extension Routing: Printer where RouteParser: Printer {
  @inlinable
  @inline(__always)
  public func print(_ output: Route) -> URLRequestData? {
    self.parser.print(output)
  }
}

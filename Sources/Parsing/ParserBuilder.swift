@resultBuilder
public enum ParserBuilder {
  @inlinable
  public static func buildBlock<P>(_ parser: P) -> P where P: Parser {
    parser
  }

  @inlinable
  public static func buildEither<TrueParser, FalseParser>(
    first parser: TrueParser
  ) -> Conditional<TrueParser, FalseParser>
  where
    TrueParser: Parser,
    FalseParser: Parser
  {
    .first(parser)
  }

  @inlinable
  public static func buildEither<TrueParser, FalseParser>(
    second parser: FalseParser
  ) -> Conditional<TrueParser, FalseParser>
  where
    TrueParser: Parser,
    FalseParser: Parser
  {
    .second(parser)
  }

  public static func buildIf<P>(
    _ parser: P?
  ) -> Conditional<P, Parsers.Fail<P.Input, P.Output>>
  where P: Parser
  {
    if let parser = parser {
      return .first(parser)
    } else {
      return .second(.init())
    }
  }

  @inlinable
  public static func buildLimitedAvailability<P>(_ component: P) -> Parsers.OptionalParser<P>
  where P: Parser {
    .init(component)
  }
}

public struct Parse<Upstream>: Parser where Upstream: Parser {
  public let upstream: Upstream

  @inlinable
  public init(@ParserBuilder _ build: () -> Upstream) {
    self.upstream = build()
  }

  @inlinable
  public func parse(_ input: inout Upstream.Input) -> Upstream.Output? {
    self.upstream.parse(&input)
  }
}

extension Parse: Printer where Upstream: Printer {
  @inlinable
  public func print(_ output: Upstream.Output) -> Upstream.Input? {
    self.upstream.print(output)
  }
}

@resultBuilder
public enum OneOfBuilder {
  @inlinable
  public static func buildArray<P>(_ parsers: [P]) -> OneOfMany<P> where P: Parser {
    OneOfMany(parsers)
  }

  @inlinable
  static public func buildBlock<P>(_ parser: P) -> P where P: Parser {
    parser
  }

  @inlinable
  public static func buildEither<TrueParser, FalseParser>(
    first parser: TrueParser
  ) -> Conditional<TrueParser, FalseParser>
  where
    TrueParser: Parser,
    FalseParser: Parser
  {
    .first(parser)
  }

  @inlinable
  public static func buildEither<TrueParser, FalseParser>(
    second parser: FalseParser
  ) -> Conditional<TrueParser, FalseParser>
  where
    TrueParser: Parser,
    FalseParser: Parser
  {
    .second(parser)
  }

  public static func buildIf<P>(
    _ parser: P?
  ) -> Conditional<P, Parsers.Fail<P.Input, P.Output>>
  where P: Parser
  {
    if let parser = parser {
      return .first(parser)
    } else {
      return .second(.init())
    }
  }

  @inlinable
  public static func buildLimitedAvailability<P>(_ component: P) -> Parsers.OptionalParser<P>
  where P: Parser {
    .init(component)
  }
}

public struct OneOf<Upstream>: Parser where Upstream: Parser {
  public let upstream: Upstream

  @inlinable
  public init(@OneOfBuilder _ build: () -> Upstream) {
    self.upstream = build()
  }

  @inlinable
  public func parse(_ input: inout Upstream.Input) -> Upstream.Output? {
    self.upstream.parse(&input)
  }
}

extension OneOf: Printer where Upstream: Printer {
  @inlinable
  public func print(_ output: Upstream.Output) -> Upstream.Input? {
    self.upstream.print(output)
  }
}

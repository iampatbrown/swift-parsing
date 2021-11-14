extension Parser {
  public func withPrinter(_ print: @escaping (Output) -> Input?) -> Parsers.WithPrinter<Self> {
    Parsers.WithPrinter(parser: self, print: print)
  }
}

extension Parsers {
  public struct WithPrinter<Upstream>: ParserPrinter where Upstream: Parser  {
    @usableFromInline
    let parser: Upstream
    @usableFromInline
    let printer: (Upstream.Output) -> Upstream.Input?

    @inlinable
    public init(
      parser: Upstream,
      print: @escaping (Upstream.Output) -> Upstream.Input?
    ) {
      self.parser = parser
      self.printer = print
    }


    @inlinable
    public func parse(_ input: inout Upstream.Input) -> Upstream.Output? {
      self.parser.parse(&input)
    }

    @inlinable
    public func print(_ output: Upstream.Output) -> Upstream.Input? {
      self.printer(output)
    }
  }
}

public struct AnyParserPrinter<Input, Output>: ParserPrinter {
  @usableFromInline
  let parser: (inout Input) -> Output?
  @usableFromInline
  let printer: (Output) -> Input?

  @inlinable
  public init(
    parse: @escaping (inout Input) -> Output?,
    print: @escaping (Output) -> Input?
  ) {
    self.parser = parse
    self.printer = print
  }

  @inlinable
  public init<P>(_ parserPrinter: P) where P: ParserPrinter, P.Input == Input, P.Output == Output {
    self.init(parse: parserPrinter.parse, print: parserPrinter.print)
  }

  @inlinable
  public func parse(_ input: inout Input) -> Output? {
    self.parser(&input)
  }

  @inlinable
  public func print(_ output: Output) -> Input? {
    self.printer(output)
  }

  @inlinable
  public func eraseToAnyParserPrinter() -> Self {
    self
  }
}

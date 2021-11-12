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

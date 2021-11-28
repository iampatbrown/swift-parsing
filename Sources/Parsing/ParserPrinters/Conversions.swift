import Foundation

public struct Conversion<Input, Output>: ParserPrinter {
  private let apply: (Input) -> Output
  private let unapply: (Output) -> Input

  public init(
    apply: @escaping (Input) -> Output,
    unapply: @escaping (Output) -> Input
  ) {
    self.apply = apply
    self.unapply = unapply
  }

  public func apply(_ input: Input) -> Output {
    self.apply(input)
  }

  public func unapply(_ output: Output) -> Input {
    self.unapply(output)
  }

  public func parse(_ input: inout Input) -> Output? {
    self.apply(input)
  }

  public func print(_ output: Output) -> Input? {
    self.unapply(output)
  }
}

public struct PartialConversion<Input, Output>: ParserPrinter {
  private let apply: (Input) -> Output?
  private let unapply: (Output) -> Input?

  public init(
    apply: @escaping (Input) -> Output?,
    unapply: @escaping (Output) -> Input?
  ) {
    self.apply = apply
    self.unapply = unapply
  }

  public func apply(_ input: Input) -> Output? {
    self.apply(input)
  }

  public func unapply(_ output: Output) -> Input? {
    self.unapply(output)
  }

  public func parse(_ input: inout Input) -> Output? {
    self.apply(input)
  }

  public func print(_ output: Output) -> Input? {
    self.unapply(output)
  }
}

extension Parser {
  public func convert<NewOutput>(
    _ conversion: Conversion<Output, NewOutput>
  ) -> Parsers.Pipe<Self, Conversion<Output, NewOutput>> {
    self.pipe(conversion)
  }

  public func convert<NewOutput>(
    apply: @escaping (Output) -> NewOutput,
    unapply: @escaping (NewOutput) -> Output
  ) -> Parsers.Pipe<Self, Conversion<Output, NewOutput>> {
    self.pipe(.init(apply: apply, unapply: unapply))
  }

  public func convert<NewOutput>(
    _ conversion: PartialConversion<Output, NewOutput>
  ) -> Parsers.Pipe<Self, PartialConversion<Output, NewOutput>> {
    self.pipe(conversion)
  }

  public func convert<NewOutput>(
    apply: @escaping (Output) -> NewOutput?,
    unapply: @escaping (NewOutput) -> Output?
  ) -> Parsers.Pipe<Self, PartialConversion<Output, NewOutput>> {
    self.pipe(.init(apply: apply, unapply: unapply))
  }
}

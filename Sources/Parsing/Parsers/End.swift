/// A parser that succeeds if the input is empty, and fails otherwise.
///
/// ```swift
/// End<Substring>().parse(""[...]) // (output: (), rest: "")
/// End<Substring>().parse("Hello"[...]) // (output: nil, rest: "Hello")
/// ```
public struct End<Input>: Parser where Input: Collection {
  @inlinable
  public init() {}

  @inlinable
  @_disfavoredOverload
  public init() where Input == Substring {}

  @inlinable
  @_disfavoredOverload
  public init() where Input == Substring.UTF8View {}

  @inlinable
  public func parse(_ input: inout Input) -> Void? {
    guard input.isEmpty else { return nil }
    return ()
  }
}

extension Parsers {
  public typealias End = Parsing.End  // NB: Convenience type alias for discovery
}


extension End: Printer where Input: Appendable {
  public func print(_ output: ()) -> Input? {
    Input()
  }
}

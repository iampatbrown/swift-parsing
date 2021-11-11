public protocol _Parser: Parser {
  associatedtype Body: Parser
  @ParserBuilder var body: Body { get }
}

public extension _Parser {
  @inlinable @inline(__always)
  func parse(_ input: inout Body.Input) -> Body.Output? {
    self.body.parse(&input)
  }
}



import Foundation

public protocol Printer {
  associatedtype Input
  associatedtype Output
  func print(_ output: Output) -> Input?
}

public typealias ParserPrinter = Parser & Printer

extension Printer where Output == Void {
  @inlinable
  public func print() -> Input? {
    self.print(())
  }
}

// MARK: -

struct User: Equatable {
  var id: Int
  var name: String
  var isAdmin: Bool
}

public func foo() {
  let user = Parse {
    Int.parser()
    ","
    Prefix { $0 != "," }.pipe { String.parser() }
    ","
    Bool.parser()
  }
  .pipe { UnsafeBitCast(User.init(id:name:isAdmin:)) }

  let a = user.parse("1,Blob,true")
  let b = user.print(User(id: 1, name: "Blob", isAdmin: true))
  print(a)
  print(b)
}

public struct UnsafeBitCast<Values, Root>: ParserPrinter {
  @usableFromInline
  let initializer: (Values) -> Root

  @inlinable
  public init(_ initializer: @escaping (Values) -> Root) {
    self.initializer = initializer
  }

  @inlinable
  public func parse(_ input: inout Values) -> Root? {
    self.initializer(input)
  }

  @inlinable
  public func print(_ output: Root) -> Values? {
    Swift.unsafeBitCast(output, to: Values.self)
  }
}

extension Parser where Self == AnyParserPrinter<Substring, String> {
  static var toString: Self {
    .init(parse: { String($0) }, print: { $0[...] })
  }
}

extension String {
  static var fromSubstring: AnyParserPrinter<Substring, String> {
    .init(parse: { String($0) }, print: { $0[...] })
  }
}

extension Parser where Self == AnyParserPrinter<String, String> {
  static var toString: Self {
    Self(parse: { String($0) }, print: { $0 })
  }
}

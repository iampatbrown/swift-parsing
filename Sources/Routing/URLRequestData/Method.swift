import Parsing

public struct Method: ParserPrinter {
  public let name: String

  public static let delete = Self("DELETE")
  public static let get = Self("GET")
  public static let head = Self("HEAD")
  public static let patch = Self("PATCH")
  public static let post = Self("POST")
  public static let put = Self("PUT")

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

  @inlinable
  public func print(_ output: Void) -> URLRequestData? {
    .init(method: self.name)
  }
}

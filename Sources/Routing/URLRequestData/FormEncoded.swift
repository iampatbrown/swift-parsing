import Foundation
import Parsing

public struct FormEncoded<Value: Codable>: ParserPrinter {
  public let decoder: URLFormDecoder

  @inlinable
  public init(
    _ type: Value.Type,
    decoder: URLFormDecoder = .init()
  ) {
    self.decoder = decoder
  }

  @inlinable
  public func parse(_ input: inout ArraySlice<UInt8>) -> Value? {
    guard
      let output = try? decoder.decode(Value.self, from: Data(input))
    else { return nil }
    input = []
    return output
  }

  @inlinable
  public func print(_ output: Value) -> ArraySlice<UInt8>? {
    return ArraySlice(urlFormEncode(value: output).utf8)
  }
}

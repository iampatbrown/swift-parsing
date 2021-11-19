import Parsing
import Foundation

public struct JSON<Value: Codable>: ParserPrinter {
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

  @inlinable
  public func print(_ output: Value) -> ArraySlice<UInt8>? {
    guard let json = try? encoder.encode(output)
    else { return nil }
    return ArraySlice(json)
  }
}

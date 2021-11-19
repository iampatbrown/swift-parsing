import Foundation
import Parsing

public struct FormField<ValueParser>: ParserPrinter
  where
  ValueParser: ParserPrinter,
  ValueParser.Input == String?
{
  public let name: String
  public let valueParser: ValueParser

  @inlinable
  public init(
    _ name: String,
    @ParserBuilder _ valueParser: () -> ValueParser
  ) {
    self.name = name
    self.valueParser = valueParser()
  }

  @inlinable
  public func parse(_ input: inout ArraySlice<UInt8>) -> ValueParser.Output? {
    let original = input
    while let pair = pairParser.parse(&input) {
      let name = pair.0
      if name == self.name {
        var value = pair.1
        guard
          let output = self.valueParser.parse(&value),
          value?.isEmpty ?? true
        else { break }
        input = []
        return output
      }
      guard pairSeparator.parse(&input) != nil else { break }
    }
    input = original
    return nil
  }

  @inlinable
  public func print(_ output: ValueParser.Output) -> ArraySlice<UInt8>? {
    guard
      let value = self.valueParser.print(output),
      let output = pairParser.print((self.name, value)) else { return nil }
    return output
  }
}

@usableFromInline
let pairSeparator = StartsWith<ArraySlice<UInt8>>("&".utf8)

@usableFromInline
let pairName = Prefix<ArraySlice<UInt8>> { $0 != .init(ascii: "=") && $0 != .init(ascii: "&") }

@usableFromInline
let pairValue = Prefix<ArraySlice<UInt8>> { $0 != .init(ascii: "&") }

@usableFromInline
let pairParser = Parse {
  pairName.map(String.fromFormEncodedBytes)
  Optionally {
    StartsWith<ArraySlice<UInt8>>("=".utf8)
    pairValue.map(String.fromFormEncodedBytes)
  }
}

extension String {
  static let fromFormEncodedBytes = PartialConversion<ArraySlice<UInt8>, Self>(
    apply: { bytes -> String? in
      String(decoding: bytes, as: UTF8.self).replacingOccurrences(of: "+", with: " ").removingPercentEncoding
    },
    unapply: { string -> ArraySlice<UInt8>? in
      guard let percentEncoded = string.addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed)
      else { return nil }
      return ArraySlice(percentEncoded.utf8)
    }
  )
}

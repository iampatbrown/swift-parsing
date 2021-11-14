import Benchmark
import CoreFoundation
import Parsing

private struct Color: Equatable {
  let red, green, blue: UInt8
}

private typealias Input = Substring.UTF8View
private typealias Output = Color

private let hexPrimary = Prefix<Input>(2).pipe {
  UInt8.parser(isSigned: false, radix: 16)
  End()
}

private let hexColor = Parse {
  "#".utf8
  hexPrimary
  hexPrimary
  hexPrimary
}
.map(Color.init(red:green:blue:))

extension Color {
  fileprivate static let fromString = PartialConversion<String, Self>.init(
    apply: hexColor.parse,
    unapply: { "#\(byteString($0.red))\(byteString($0.green))\(byteString($0.blue))" }
  )
}

private func byteString(_ byte: UInt8) -> String {
  //  String(format: "%02X", byte) is pretty slow
  byte < 16 ? "0" + String(byte, radix: 16, uppercase: true) : String(byte, radix: 16, uppercase: true)
}



let colorSuite = BenchmarkSuite(name: "Color") { suite in
  let input = "#FF0000"
  let expected = Color(red: 0xFF, green: 0x00, blue: 0x00)
  var output: Output!

  suite.benchmark(
    name: "Parser",
    run: { output = hexColor.parse(input) },
    tearDown: { precondition(output == expected) }
  )

  suite.benchmark(
    name: "Conversion.apply",
    run: { output = Color.fromString.apply(input) },
    tearDown: { precondition(output == expected) }
  )

  var hexString: String!
  suite.benchmark(
    name: "Conversion.unapply",
    run: { hexString = Color.fromString.unapply(expected) },
    tearDown: { precondition(hexString == input) }
  )
}

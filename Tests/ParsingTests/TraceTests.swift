import Parsing
import XCTest

func printOutput() {
  var output = ""
  Trace.default.print(to: &output)
  Trace.default.clear()
  print("\n--------\n")
  print(output)
  print("\n--------\n")
}

final class TraceTests: XCTestCase {
  func testTraceGood() {
    var input = "42 Hello, world!"[...]
    _ = Prefix(while: { $0.isNumber }).trace().parse(&input)
//    _ = Prefix(while: { $0.isNumber }).trace().parse(&input)

    printOutput()
  }

  func testTraceBad() {
    var input = "42 Hello, world!"[...]

    _ = Prefix(100...).trace().parse(&input)

    printOutput()
  }

  func testTraceNested() {
    var input = "42 Hello, world!"[...]
    _ = Parse {
      OneOf {
        PrefixUpTo("Goodbye").trace()

        Prefix(while: { $0.isNumber }).trace()
      }.trace()

      Skip {
        Prefix(while: { $0 == " " })
      }.trace()

      Rest().trace()
    }.trace()
      .parse(&input)

    printOutput()
  }

  func testTraceNestedWithNames() {
    var input = "42 Hello, world!"[...]
    _ = Parse {
      OneOf {
        PrefixUpTo("Goodbye").trace("goodbye")

        Prefix(while: { $0.isNumber }).trace("number")
      }.trace("prefix")

      Skip {
        Prefix(while: { $0 == " " })
      }.trace("skip whitespace")

      Rest().trace().trace("rest")
    }.trace("root")
      .parse(&input)

    printOutput()
  }
}

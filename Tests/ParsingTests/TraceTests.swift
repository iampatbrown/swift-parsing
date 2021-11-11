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
//    _ = Prefix(while: { $0.isNumber }).signpost().parse(&input)
    _ = Prefix(while: { $0.isNumber }).signpost().parse(&input)

    printOutput()
  }

  func testTraceBad() {
    var input = "42 Hello, world!"[...]

    _ = Prefix(100...).signpost().parse(&input)

    printOutput()
  }

  func testTraceNested() {
    var input = "42 Hello, world!"[...]
    _ = Parse {
      OneOf {
        PrefixUpTo("Goodbye").signpost()

        Prefix(while: { $0.isNumber }).signpost()
      }.signpost()

      Skip {
        Prefix(while: { $0 == " " })
      }.signpost()

      Rest().signpost()
    }.signpost()
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

      Rest().signpost().trace("rest")
    }.trace("root")
      .parse(&input)

    printOutput()
  }
}

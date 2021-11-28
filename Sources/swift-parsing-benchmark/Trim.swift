import Benchmark
import Parsing

let trimSuite = BenchmarkSuite(name: "Trim") { suite in
  let input = Array(repeating: " ", count: 1000).joined() + "ABC" + Array(repeating: " ", count: 1000).joined()

  suite.benchmark("trimmingCharacters(in: .whitespacesAndNewlines)") {
    var input = input
    let output = input.trimmingCharacters(in: .whitespacesAndNewlines)
    precondition(output == "ABC")
  }

  suite.benchmark("Trim") {
    var input = input[...].utf8
    let output = Trim(upstream: Whitespace()).parse(&input)
    precondition(String(output!)! == "ABC")
  }

  func isWhitespace(byte: UTF8.CodeUnit) -> Bool {
    byte == .init(ascii: " ")
      || byte == .init(ascii: "\n")
      || byte == .init(ascii: "\r")
      || byte == .init(ascii: "\t")
  }

  suite.benchmark("TrimWhile") {
    var input = input[...].utf8
    let output = TrimWhile(isWhitespace).parse(&input)
    precondition(String(output!)! == "ABC")
  }
}

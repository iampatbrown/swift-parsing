import Benchmark
import Parsing

let replacingOccurrencesSuite = BenchmarkSuite(name: "replacingOccurrences") { suite in
  let input = (0...1000).map { "\($0)+" }.joined()
  let expected = (0...1000).map { "\($0) " }.joined()

  suite.benchmark("replacingOccurrences(of:,with:)") {
    var input = input
    let output = input.replacingOccurrences(of: "+", with: " ")
    precondition(output == expected)
  }


  let replacingPlusWithSpace = Many(into: "") { $0 += $1 } forEach :{
    OneOf {
      Prefix { $0 != "+" }
      "+".map { " "[...] }
    }
  }
//
//  suite.benchmark("adhoc") {
//    var input = input[...]
//    let output = replacingPlusWithSpace.parse(&input)
//    precondition(output! == expected)
//  }


  suite.benchmark("ReplacingOccurrences") {
    var input = input[...].utf8
    let output = ReplacingOccurrences(of: "+"[...].utf8, with: " "[...].utf8, by: ==).parse(&input)
    precondition(String(output!)! == expected)
  }
}

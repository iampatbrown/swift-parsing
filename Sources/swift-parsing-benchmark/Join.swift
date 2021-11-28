import Benchmark
import Parsing

let joinSuite = BenchmarkSuite(name: "joined") { suite in
  let input = (0...1000).map { "\($0)+" }
  let expected = input.joined()
  let flattened = input.flatMap { $0 }
  suite.benchmark("joined()") {
    var input = input
    let output = input.joined()
    precondition(output == expected)
  }

//  let replacingPlusWithSpace = Many(into: "") { $0 += $1 } forEach :{
//    OneOf {
//      Prefix { $0 != "+" }
//      "+".map { " "[...] }
//    }
//  }
  ////
//  suite.benchmark("adhoc") {
//    var input = input[...]
//    let output = replacingPlusWithSpace.parse(&input)
//    precondition(output! == expected)
//  }

  suite.benchmark("Join") {
    var input = input
    let output = Join().parse(&input)
    precondition(output == expected)
  }

  suite.benchmark("JoinArraySlice") {
    var input = input[...]
    let output = Join().parse(&input)
    precondition(output == expected)
  }
}
